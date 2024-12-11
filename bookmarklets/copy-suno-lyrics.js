// Bookmarklet to copy the lyrics of a Suno song to the user's clipboard

// Tested on https://suno.com/song/... on 2024-12-11 with
// Google Chrome version 130.0.6723.59 (Official Build) (64-bit)

// javascript:(function(){

const content = document
  .getElementsByTagName("textarea")[0]
  .value.trim()
  .replaceAll("\r", "")
  .split("\n")
  .map((line) => line.trim())
  .join("\n");

navigator.clipboard
  .writeText(content)
  .then(() => {
    alert(`Copied to clipboard:\n\n${content}`);
  })
  .catch((error) => {
    alert("Error copying to clipboard: " + error);
  });

// })();
