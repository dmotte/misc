// Bookmarklet to spawn a button that makes the page go fullscreen

// Tested with Google Chrome version 130.0.6723.59 (Official Build) (64-bit)

// javascript:(function(){

const btnFullscreen = document.createElement("button");

btnFullscreen.textContent = "GO FULLSCREEN";

btnFullscreen.style.position = "fixed";
btnFullscreen.style.top = "50%";
btnFullscreen.style.left = "50%";
btnFullscreen.style.transform = "translate(-50%, -50%)";

btnFullscreen.style.zIndex = "9999";

btnFullscreen.style.cursor = "pointer";

btnFullscreen.style.backgroundColor = "#000";
btnFullscreen.style.color = "#fff";

btnFullscreen.style.fontSize = "20px";
btnFullscreen.style.fontWeight = "bold";

btnFullscreen.style.border = "1px solid #fff";
btnFullscreen.style.padding = "20px 30px";

btnFullscreen.addEventListener("click", () => {
  document.documentElement.requestFullscreen().catch((error) => {
    alert("Error: " + error);
  });
  btnFullscreen.remove();
});

document.body.appendChild(btnFullscreen);

// })();
