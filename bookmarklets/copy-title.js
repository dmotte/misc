// Bookmarklet to copy the page title to the user's clipboard

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
