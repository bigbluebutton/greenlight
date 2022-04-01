// Entry point for the build script in your package.json
import "@hotwired/turbo-rails";
import React from "react";
import { render } from "react-dom";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import {QueryClient, QueryClientProvider} from "react-query";
import App from "./app";
import Signup from "./routes/Signup";
import SignIn from './components/sessions/SignIn';
import AuthProvider from './components/sessions/AuthContext';
import RoomView from "./components/rooms/RoomView";
import Rooms from "./components/rooms/Rooms";

const queryClient = new QueryClient()

const root = (
     <QueryClientProvider client={queryClient}>
       <AuthProvider>
          <Router>
              <Routes>
                 <Route path="/" element={<App />}>
                   <Route index element={<h1 className="text-center">Index</h1>} />
                   <Route path="/signup" element={<Signup />} />
                   <Route path="/sign_in" element={<SignIn />} />
                   <Route path="/rooms" element={<Rooms/>} />
                   <Route path="/rooms/:friendly_id" element={<RoomView />} />
                   <Route path="*" element={<h1 className="text-center">404</h1>} />
                 </Route>
              </Routes>
          </Router>
       </AuthProvider>
     </QueryClientProvider>
 )

const rootElement = document.getElementById('root')
render(root, rootElement)
