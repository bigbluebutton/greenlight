import { useMutation, useQueryClient } from 'react-query';
import { toast } from 'react-hot-toast';
import axios from '../../../../helpers/Axios';

export default function useUpdateRoomConfig(name) {
  const queryClient = useQueryClient();

  return useMutation(
    (RoomsConfig) => axios.patch(`/admin/rooms_configurations/${name}.json`, { RoomsConfig }),
    {
      onError: () => { toast.error('There was a problem completing that action. \n Please try again.'); },
      onSuccess: () => {
        toast.success('Room configuration updated');
        queryClient.invalidateQueries('getRoomsConfigs');
      },
    },
  );
}
