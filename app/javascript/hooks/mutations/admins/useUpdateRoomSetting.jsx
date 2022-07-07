import { useMutation } from 'react-query';
import { toast } from 'react-hot-toast';
import axios from '../../../helpers/Axios';

export default function useUpdateRoomSetting() {
  // const queryClient = useQueryClient();

  return useMutation(
    (roomSettingData) => axios.post('/admin/room_settings/update.json', roomSettingData),
    {
      onSuccess: () => {
        // TODO: Need to re-fetch room settings?

        toast.success('Room Settings updated');
      },
      onError: () => {
        toast.error('There was a problem completing that action. \n Please try again.');
      },
    },
  );
}
