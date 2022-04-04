import React from "react"
import {useQuery} from "react-query";
import axios from "axios";

export default function useSessions() {
  return useQuery("useSessions", async() =>
    await axios.get(`/api/v1/sessions.json`, {
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      }
    }).then(resp => resp.data)
  );
}