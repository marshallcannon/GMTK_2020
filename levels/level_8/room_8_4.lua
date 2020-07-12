return {
  version = "1.2",
  luaversion = "5.1",
  tiledversion = "1.3.5",
  orientation = "orthogonal",
  renderorder = "right-down",
  width = 10,
  height = 10,
  tilewidth = 32,
  tileheight = 32,
  nextlayerid = 3,
  nextobjectid = 15,
  properties = {},
  tilesets = {
    {
      name = "allTiles",
      firstgid = 1,
      filename = "../allTiles.tsx",
      tilewidth = 32,
      tileheight = 32,
      spacing = 0,
      margin = 0,
      columns = 0,
      tileoffset = {
        x = 0,
        y = 0
      },
      grid = {
        orientation = "orthogonal",
        width = 1,
        height = 1
      },
      properties = {},
      terrains = {},
      tilecount = 7,
      tiles = {
        {
          id = 0,
          image = "../../assets/images/block.png",
          width = 32,
          height = 32
        },
        {
          id = 1,
          image = "../../assets/images/marine.png",
          width = 32,
          height = 32
        },
        {
          id = 2,
          image = "../../assets/images/alien.png",
          width = 32,
          height = 32
        },
        {
          id = 3,
          image = "../../assets/images/battery.png",
          width = 32,
          height = 32
        },
        {
          id = 4,
          image = "../../assets/images/spikesTop.png",
          width = 32,
          height = 32
        },
        {
          id = 5,
          image = "../../assets/images/spikesBottom.png",
          width = 32,
          height = 32
        },
        {
          id = 6,
          image = "../../assets/images/glass.png",
          width = 32,
          height = 32
        }
      }
    }
  },
  layers = {
    {
      type = "tilelayer",
      id = 1,
      name = "Tile Layer 1",
      x = 0,
      y = 0,
      width = 10,
      height = 10,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "lua",
      data = {
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        1, 0, 0, 0, 0, 0, 0, 0, 0, 1,
        1, 7, 1, 1, 1, 1, 1, 1, 1, 1,
        1, 0, 0, 0, 0, 0, 0, 0, 0, 1,
        1, 7, 1, 1, 1, 1, 1, 1, 1, 1,
        1, 0, 0, 0, 0, 0, 0, 0, 0, 1,
        1, 7, 1, 1, 1, 1, 1, 1, 1, 1,
        1, 0, 0, 0, 0, 0, 0, 0, 0, 1,
        1, 0, 0, 0, 0, 0, 0, 0, 0, 1,
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1
      }
    },
    {
      type = "objectgroup",
      id = 2,
      name = "Object Layer 1",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      draworder = "topdown",
      properties = {},
      objects = {
        {
          id = 1,
          name = "",
          type = "",
          shape = "rectangle",
          x = 32,
          y = 64,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 3,
          visible = true,
          properties = {}
        },
        {
          id = 2,
          name = "",
          type = "",
          shape = "rectangle",
          x = 32,
          y = 128,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 3,
          visible = true,
          properties = {}
        },
        {
          id = 3,
          name = "",
          type = "",
          shape = "rectangle",
          x = 32,
          y = 192,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 3,
          visible = true,
          properties = {}
        },
        {
          id = 4,
          name = "",
          type = "",
          shape = "rectangle",
          x = 32,
          y = 288,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 2,
          visible = true,
          properties = {}
        },
        {
          id = 6,
          name = "",
          type = "",
          shape = "rectangle",
          x = 96,
          y = 288,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 6,
          visible = true,
          properties = {}
        },
        {
          id = 7,
          name = "",
          type = "",
          shape = "rectangle",
          x = 160,
          y = 256,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 5,
          visible = true,
          properties = {}
        },
        {
          id = 8,
          name = "",
          type = "",
          shape = "rectangle",
          x = 224,
          y = 288,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 6,
          visible = true,
          properties = {}
        },
        {
          id = 12,
          name = "",
          type = "",
          shape = "rectangle",
          x = 160,
          y = 192,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 6,
          visible = true,
          properties = {}
        },
        {
          id = 13,
          name = "",
          type = "",
          shape = "rectangle",
          x = 192,
          y = 128,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 6,
          visible = true,
          properties = {}
        },
        {
          id = 14,
          name = "",
          type = "",
          shape = "rectangle",
          x = 224,
          y = 64,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 6,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
