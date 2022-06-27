import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';
import axios from '../../../helpers/Axios';

export default function useUpdateRecordingVisibility() {
  const updateRecordingVisibility = (visibilityData) => axios.post('/recordings/update_visibility.json', visibilityData);

  const queryClient = useQueryClient();
  const mutation = useMutation(updateRecordingVisibility, {
    onSuccess: () => {
      toast.success('Recording visibility updated');
      queryClient.invalidateQueries('getRecordings');
    },
  });

  const handleUpdateRecordingVisibility = (visibilityData) => mutation.mutateAsync(visibilityData)
    .catch(/* Prevents the promise exception from bubbling */() => {});
  return { handleUpdateRecordingVisibility, ...mutation };
}
