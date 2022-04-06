import React from 'react';
import renderer from 'react-test-renderer';
import Rooms from '../../components/rooms/Rooms';
import RoomsList from '../../components/rooms/RoomsList';
import RoomsTabs from '../../components/rooms/RoomsTabs';
import useRooms from '../../hooks/queries/rooms/__mocks__/useRooms';

jest.mock('react-router-dom');
jest.mock('../../hooks/queries/rooms/useRooms');

const rooms = {
  data:
    [
      {
        name: 'Home Room',
        friendly_id: 'dummy_id1',
      },
      {
        name: 'Room 1',
        friendly_id: 'dummy_id2',
      },
      {
        name: 'Room 2',
        friendly_id: 'dummy_id3',
      },
    ],
};

describe('Rooms (useRooms query test)', () => {
  test('Rooms from query match expected rooms', () => {
    const json = useRooms();
    expect(json).toMatchObject(rooms);
  });
});

describe('Rooms (Snapshot Tests)', () => {
  it('Rooms renders rooms', () => {
    const roomsComponent = renderer.create(<Rooms />);
    const json = roomsComponent.toJSON();
    expect(json).toMatchSnapshot();
  });

  it('RoomsTab renders room nav tabs', () => {
    const roomsTabsComponent = renderer.create(<RoomsTabs />);
    const json = roomsTabsComponent.toJSON();
    expect(json).toMatchSnapshot();
  });

  it('RoomsList renders list of rooms', () => {
    const roomsListComponent = renderer.create(<RoomsList />);
    const json = roomsListComponent.toJSON();
    expect(json).toMatchSnapshot();
  });
});
