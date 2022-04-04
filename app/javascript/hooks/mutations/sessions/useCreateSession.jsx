import {useMutation, useQueryClient} from "react-query";
import axios, { ENDPOINTS } from "../../../helpers/Axios";
import {useNavigate} from "react-router";

const createSession = (sessionUser) => axios.post(ENDPOINTS.signin, sessionUser)
  .then((resp) => resp.data)
  .catch((error) => console.log(error));

export function useCreateSession(options){
  const queryClient = useQueryClient();
  const navigate = useNavigate();

  const mutation = useMutation(createSession, {
    // Re-fetch the current_user and redirect to homepage if Mutation is successful.
    onSuccess: () => {
      queryClient.invalidateQueries('useSessions');
      navigate('/rooms');
    },
    onError: (error) => {
      console.log('mutate error', error);
    },
  });

  const onSubmit = (user_data) => mutation.mutateAsync({ user: user_data }).catch(/*Prevents the promise exception from bubbling*/()=>{})
  return { onSubmit, ...mutation }
}
