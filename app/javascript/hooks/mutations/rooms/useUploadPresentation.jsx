import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';
import axios from '../../../helpers/Axios';

export default function useUploadPresentation(friendlyId) {
  const queryClient = useQueryClient();

  const uploadPresentation = (data) => {
    const formData = new FormData();
    formData.append('room[presentation]', data);
    return axios.patch(`/rooms/${friendlyId}.json`, formData);
  };

  const mutation = useMutation(uploadPresentation, {
    onSuccess: () => {
      queryClient.invalidateQueries('getRoom');
      toast.success('Presentation uploaded');
    },
    onError: () => {
      toast.error('There was a problem completing that action. \n Please try again.');
    },
  });

  const onSubmit = async (data) => {
    await mutation.mutateAsync(data).catch(/* Prevents the promise exception from bubbling */() => {});
  };
  return { onSubmit, ...mutation };
}
