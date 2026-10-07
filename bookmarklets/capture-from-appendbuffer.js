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
  if (
    typeof window.__capture_from_appendbuffer_chunksBySrcBuf !== "undefined"
  ) {
    alert("Detected MSE chunks capture already running");
    return;
  }

  window.__capture_from_appendbuffer_chunksBySrcBuf = new WeakMap();
  const chunksBySrcBuf = window.__capture_from_appendbuffer_chunksBySrcBuf;

  console.info("Starting MSE chunks capture with WeakMap %O", chunksBySrcBuf);

  function interceptAppendBuffer(sourceBuffer, data) {
    const bytes = (
      ArrayBuffer.isView(data)
        ? new Uint8Array(data.buffer, data.byteOffset, data.byteLength)
        : new Uint8Array(data)
    ).slice(); // We call ".slice()" to create a clone here

    if (!chunksBySrcBuf.has(sourceBuffer)) chunksBySrcBuf.set(sourceBuffer, []);
    const chunks = chunksBySrcBuf.get(sourceBuffer);

    if (
      chunks.length > 0 &&
      getBoxType(chunks.at(-1)) !== "ftyp" &&
      getBoxType(bytes) === "ftyp"
    ) {
      console.info(
        "SourceBuffer %O: ftyp chunk %O detected after a non-ftyp chunk. " +
          "Resetting and starting download of captured MSE stream %O",
        sourceBuffer,
        bytes,
        chunks,
      );
      chunksBySrcBuf.set(sourceBuffer, []);
      downloadMSEStream(chunks);

      return;
    }

    console.info(
      "SourceBuffer %O: capturing MSE chunk %O with box type %o",
      sourceBuffer,
      bytes,
      getBoxType(bytes),
    );
    chunks.push(bytes);
  }

  const originalAppendBuffer = SourceBuffer.prototype.appendBuffer;
  SourceBuffer.prototype.appendBuffer = function (data) {
    interceptAppendBuffer(this, data);
    return originalAppendBuffer.call(this, data);
  };

  alert("Started MSE chunks capture. Please open the browser console now");

  // querySelectorOrErr("button#btnPlay").click();
  // querySelectorOrErr("audio#mymedia").playbackRate = 10;
} catch (error) {
  handleBookmarkletError(error);
}

// })();
