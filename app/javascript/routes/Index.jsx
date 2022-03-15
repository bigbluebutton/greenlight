import React from "react";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import SignIn from "../components/sessions/SignIn";
import Home from '../components/Home';

export default (
  <Router>
    <Routes>
      <Route path="/" element={<Home />} />
      <Route path="/sign_in" element={<SignIn />} />
    </Routes>
  </Router>
);
