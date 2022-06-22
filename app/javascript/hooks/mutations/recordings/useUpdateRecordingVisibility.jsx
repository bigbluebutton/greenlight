import { useMutation, useQueryClient } from 'react-query';
import axios from 'axios';
import { toast } from 'react-hot-toast';

export default function useUpdateRecordingVisibility() {
  const updateRecordingVisibility = (visibilityData) => axios.post('/api/v1/recordings/update_visibility.json', visibilityData);

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
