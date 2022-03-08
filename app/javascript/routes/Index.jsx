import React from "react";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import Test from "../components/Test";
import OtherTest from "../components/OtherTest";

export default (
  <Router>
    <Routes>
      <Route path="/" element={<Test />} />
      <Route path="/othertest" element={<OtherTest />} />
    </Routes>
  </Router>
);