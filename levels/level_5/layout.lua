return {
  rooms = {
    {'room_5_1', 'room_5_2', 'room_5_3'},
    {'room_5_8', 0, 'room_5_4'},
    {'room_5_7', 'room_5_6', 'room_5_5'}
  },
  order = {
    {1, 2, 3},
    {8, '', 4},
    {7, 6, 5}
  },
  locks = {
    {0, 'move', 'jump'},
    {'move', 0, 'shoot'},
    {'shoot', 'jump', 'move'}
  }
}