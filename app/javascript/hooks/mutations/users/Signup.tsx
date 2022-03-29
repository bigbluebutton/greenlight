
import { SubmitHandler } from "react-hook-form";
import { useMutation } from "react-query";
import axios, { ENDPOINTS } from "../../../helpers/Axios";
import { SignupFormInputs } from "../../../helpers/forms/SignupFormHelpers";

const createUser = (data) => axios.post( ENDPOINTS.singup, data )

export function usePostUsers(){
    const mutation = useMutation( createUser,
        {   // Mutation config.
            mutationKey: ENDPOINTS.singup,
            onError: (error: Error) => { console.error('Error:',error.message) },
            onSuccess: (response, data) => { console.info('Success, sent:',data,', got:',response) },
        }
    )
    const onSubmit: SubmitHandler<SignupFormInputs> = (user_data) => mutation.mutateAsync({ user: user_data }).catch(/*Prevents the promise exception from bubbling*/()=>{})
    return { onSubmit, ...mutation }
}
