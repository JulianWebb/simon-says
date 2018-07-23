--! functions.lua
-- just some basic helper functions

--< Generate sequence for player to follow
function genSeq(size)
	seq = {}
	for i=1, size do
		table.insert(seq, math.random(1, 4))
	end
	return seq
end
--/> genSeq