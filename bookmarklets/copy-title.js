// Bookmarklet to copy the page title to the user's clipboard

// Tested with Google Chrome version 130.0.6723.59 (Official Build) (64-bit)

// javascript:(function(){

const content = document.title;

navigator.clipboard
  .writeText(content)
  .then(() => {
    alert(`Copied to clipboard:\n\n${content}`);
  })
  .catch((error) => {
    alert("Error copying to clipboard: " + error);
  });

// })();
