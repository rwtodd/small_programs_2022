-- just checking out lua coroutines again, making sure I remember how they work...

function counter(n)
  return coroutine.wrap(function()
    local i = 1
    while true do
      coroutine.yield(i)
      i = n + i
    end
  end)
end

function doubler(src)
  return coroutine.wrap(function()
    for v in src do 
      coroutine.yield(v)
      coroutine.yield(v)
    end
  end)
end

function summer(src,n)
  local sum = 0
  for i = 1,n do sum = sum + src() end
  return sum
end

print(summer(doubler(counter(2)),50))

-- vim: filetype=lua : sw=2 : ts=2 : sts=2 : expandtab
