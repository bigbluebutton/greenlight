import { useMutation } from 'react-query';
import { toast } from 'react-hot-toast';
import axios, { ENDPOINTS } from '../../../helpers/Axios';

export default function useStartMeeting(friendlyId) {
  const startMeeting = () => axios.post(ENDPOINTS.start_meeting(friendlyId));
  const mutation = useMutation(
    startMeeting,
    { // Mutation config.
      mutationKey: ENDPOINTS.start_meeting(friendlyId),
      onError: () => { toast.error('There was a problem completing that action. \n Please try again.'); },
      onSuccess: (response, data) => { console.info('Success, sent:', data, ', got:', response); },
    },
  );
  const handleStartMeeting = async () => {
    try {
      const response = await mutation.mutateAsync();
      const { join_url: joinUrl } = response.data.data; // TODO: amir - Simplify this.
      window.location.href = joinUrl;
    } catch (e) { /* TODO: amir - Revisit this. */ }
  };

  return { handleStartMeeting, ...mutation };
}
