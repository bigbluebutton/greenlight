// Entry point for the build script in your package.json
import "@hotwired/turbo-rails";
import React from "react";
import { render } from "react-dom";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import App from "./app";
import Signup from "./routes/Signup";


 const root = (
  <Router>
    <Routes>
      <Route path="/" element={<App />}>
        <Route index element={<h1 className="text-center">Index</h1>} />
        <Route path="/signup" element={<Signup />} />
        <Route path="*" element={<h1 className="text-center">404</h1>} />
      </Route>
    </Routes>
  </Router>
 )


const rootElement = document.getElementById('root')
render(root, rootElement)