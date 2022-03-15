// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import React from "react"
import { render } from "react-dom"
import { QueryClient, QueryClientProvider } from 'react-query';
import App from "./components/App";


const queryClient = new QueryClient();

document.addEventListener("DOMContentLoaded", () => {
  render(
    <QueryClientProvider client={queryClient}>
      <App />
    </QueryClientProvider>,
    document.body.appendChild(document.createElement('div'))
  );
});
