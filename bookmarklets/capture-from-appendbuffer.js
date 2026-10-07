// Bookmarklet to intercept MSE (Media Source Extensions) chunks via
// SourceBuffer.appendBuffer and save the captured output to a file

// Tested with Google Chrome version 153.0.8010.36 (Official Build) (x86_64)

// javascript:(function(){

"use strict";

function handleBookmarkletError(error) {
  console.error(error);
  alert(`ERROR: ${error}`);
}

function querySelectorOrErr(selectors) {
  const result = document.querySelector(selectors);
  if (result === null) throw new Error(`Element ${selectors} not found`);
  return result;
}

function getBoxType(chunk) {
  return String.fromCharCode(...chunk.subarray(4, 8));
}

function downloadMSEStream(chunks) {
  const blob = new Blob(chunks, { type: "application/octet-stream" });
  const url = URL.createObjectURL(blob);

  const link = document.createElement("a");
  link.href = url;
  link.download = "capture.bin";
  link.click();

  link.remove();
  setTimeout(() => URL.revokeObjectURL(url), 10_000);
}

try {
  alert("Starting MSE chunks capture. Please open the browser console now");
  console.info("Starting MSE chunks capture");

  const chunks = [];

  const originalAppendBuffer = SourceBuffer.prototype.appendBuffer;
  SourceBuffer.prototype.appendBuffer = function (data) {
    const bytes = ArrayBuffer.isView(data)
      ? new Uint8Array(data.buffer, data.byteOffset, data.byteLength)
      : new Uint8Array(data);

    if (
      chunks.length > 0 &&
      getBoxType(chunks.at(-1)) !== "ftyp" &&
      getBoxType(bytes) === "ftyp"
    ) {
      console.info(
        "Chunk with box type ftyp detected after a " +
          "non-ftyp chunk. Stopping capture",
      );
      SourceBuffer.prototype.appendBuffer = originalAppendBuffer;

      console.info("Starting download of captured MSE stream");
      downloadMSEStream(chunks);
    } else {
      console.info(
        "Capturing MSE chunk with len %o and start %o",
        bytes.byteLength,
        [...bytes.subarray(0, 32)]
          .map((x) => x.toString(16).padStart(2, "0"))
          .join(" "),
      );

      // We call ".slice()" here to create a clone
      chunks.push(bytes.slice());
    }

    return originalAppendBuffer.call(this, data);
  };

  // querySelectorOrErr("button#btnPlay").click();
  // querySelectorOrErr("audio#mymedia").playbackRate = 10;
} catch (error) {
  handleBookmarkletError(error);
}

// })();
