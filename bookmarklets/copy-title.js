// Bookmarklet to copy the page title to the user's clipboard

// Tested with Google Chrome version 130.0.6723.59 (Official Build) (64-bit)

// javascript:(function(){

function handleBookmarkletError(error) {
  console.error(error);
  alert(`ERROR: ${error}`);
}

try {
  const content = document.title;

  navigator.clipboard
    .writeText(content)
    .then(() => {
      alert(`Copied to clipboard:\n\n${content}`);
    })
    .catch((error) => {
      handleBookmarkletError(error);
    });
} catch (error) {
  handleBookmarkletError(error);
}

// })();
