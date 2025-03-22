// Bookmarklet to approve an already merged GitHub PR (Pull Request)

// Tested on https://github.com/.../.../pull/.../files on 2025-03-20 with
// Google Chrome version 130.0.6723.59 (Official Build) (64-bit)

// javascript:(function(){

function querySelectorOrErr(selectors) {
  const result = document.querySelector(selectors);
  if (result === null) throw new Error(`Element ${selectors} not found`);
  return result;
}

try {
  const inputReviewEvent = querySelectorOrErr(
    "input[type='hidden'][name='pull_request_review[event]']",
  );
  const formSubmitReview = querySelectorOrErr(
    "form#pull_requests_submit_review",
  );

  inputReviewEvent.value = "approve";

  formSubmitReview.submit();
} catch (error) {
  alert("Error: " + error);
}

// })();
