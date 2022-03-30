
import { useMutation } from "react-query";
import axios, { ENDPOINTS } from "../../../helpers/Axios";

const createUser = (data) => axios.post( ENDPOINTS.signup, data )

export function usePostUsers(){
    const mutation = useMutation( createUser,
        {   // Mutation config.
            mutationKey: ENDPOINTS.signup,
            onError: (error) => { console.error('Error:',error.message) },
            onSuccess: (response, data) => { console.info('Success, sent:',data,', got:',response) },
        }
    )
    const onSubmit = (user_data) => mutation.mutateAsync({ user: user_data }).catch(/*Prevents the promise exception from bubbling*/()=>{})
    return { onSubmit, ...mutation }
}
