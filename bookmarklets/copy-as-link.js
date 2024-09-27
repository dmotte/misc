// Bookmarklet to copy a page URL and title as link (in rich text format) to
// the user's clipboard

// javascript:(function(){

function xmlescape(x) {
  return x
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&apos;");
}

const contentHTML = `<a href="${xmlescape(window.location.href)}">${xmlescape(
  document.title,
)}</a>`;
const contentPlain = document.title;

navigator.clipboard
  .write([
    new ClipboardItem({
      "text/html": new Blob([contentHTML], { type: "text/html" }),
      "text/plain": new Blob([contentPlain], { type: "text/plain" }),
    }),
  ])
  .then(() => {
    alert(`Copied to clipboard:\n\n${contentHTML}\n\n${contentPlain}`);
  })
  .catch((error) => {
    alert("Error copying to clipboard: " + error);
  });

// })();
