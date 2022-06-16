import { useQuery } from 'react-query';
import axios from 'axios';

export default function useRoomRecordingsProcessing(friendlyId) {
  return useQuery('useRoomRecordingsProcessing', () => axios.get(`/api/v1/rooms/${friendlyId}/recordings_processing.json`, {
    headers: {
      'Content-Type': 'application/json',
      Accept: 'application/json',
    },
  }).then((resp) => resp.data.data));
}
