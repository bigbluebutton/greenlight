import React from "react"
import {useQuery} from "react-query";
import axios from "axios";

export default function useRoom(friendly_id) {
  return useQuery("getRoom", () =>
    axios.get(`/api/v1/rooms/${friendly_id}.json`, {
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      }
    }).then(resp => resp.data.data)
  );
}