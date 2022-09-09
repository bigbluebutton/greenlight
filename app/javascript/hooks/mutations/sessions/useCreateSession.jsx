import { useMutation, useQueryClient } from 'react-query';
import { useNavigate } from 'react-router-dom';
import { toast } from 'react-hot-toast';
import axios from '../../../helpers/Axios';

export default function useCreateSession(token) {
  const queryClient = useQueryClient();
  const navigate = useNavigate();

  return useMutation(
    (session) => axios.post('/sessions.json', { session, token }),
    {
      onSuccess: (response) => {
        queryClient.invalidateQueries('useSessions');
        // if the current user does NOT have the CreateRoom permission, then do not re-direct to rooms page
        if (response.data.data.permissions.CreateRoom === 'false') {
          navigate('/home');
        } else {
          navigate('/rooms');
        }
      },
      onError: () => {
        toast.error('Incorrect username or password. \n Please try again');
      },
    },
  );
}
