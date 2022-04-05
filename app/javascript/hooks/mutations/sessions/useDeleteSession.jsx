import React from 'react';
import { useMutation, useQueryClient } from 'react-query';
import axios from 'axios';


export default function useDeleteSession() {
  const queryClient = useQueryClient();
  return useMutation(() => axios.delete('/api/v1/sessions/sign_out.json').then((res) => res.data), {
    onError: (error) => {
      console.log(error);
    },
    onSuccess: (response) => {
      queryClient.invalidateQueries('current_user');
      console.log(response);
    },
  });
}
