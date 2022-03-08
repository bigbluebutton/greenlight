// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import React from "react"
import { render } from "react-dom"
import App from "./components/App";

document.addEventListener("DOMContentLoaded", () => {
  render(
    <App />,
    document.getElementById("react-app")
  );
});