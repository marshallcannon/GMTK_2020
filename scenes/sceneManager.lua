local SceneManager = {
  sceneList = {}
}

function SceneManager:add (scene)

  table.insert(self.sceneList, scene)
  return scene

end

function SceneManager:remove (scene)

  for i = 1, #self.sceneList do

    if self.sceneList[i] == scene then
      table.remove(self.sceneList, i)
      return
    end

  end

end

function SceneManager:update (dt)

  for i = 1, #self.sceneList do
    self.sceneList[i]:update(dt)
  end

end

function SceneManager:draw ()

  for i = 1, #self.sceneList do
    self.sceneList[i]:draw()
  end

end

function SceneManager:keypressed (key)

  for i = 1, #self.sceneList do
    self.sceneList[i]:keypressed(key)
  end

end

return SceneManager