
import { useMutation } from "react-query";
import axios, { ENDPOINTS } from "../../../helpers/Axios";

export default function usePostStartSession(room_id) {
    const startSession = () => axios.post( ENDPOINTS.start_session(room_id) )
    const mutation = useMutation( startSession,
        {   // Mutation config.
            mutationKey: ENDPOINTS.start_session(room_id) ,
            onError: (error) => { console.error('Error:',error.message) },
            onSuccess: (response, data) => { console.info('Success, sent:',data,', got:',response) },
        }
    )
    const handleStartSession = async () => {
        try
        {
            const response = await mutation.mutateAsync()
            const join_url = response.data.data.join_url // TODO: amir - Simplify this.
            window.location.href = join_url
        }catch(e){/* TODO: amir - Revisit this. */}   
    }

    return { handleStartSession, ...mutation }
}

