
expected = { }
expindex = 1
array = { "ciao", "hello", "au revoir" }
array2 = { "arrivederci", "goodbye", "bonjour" }
array3 = { { say="ciao", lang="ita" },  { say="hello", lang="eng" },  }
testname = ""
allok = true


function assertneq(v1, v2)
	if (v1 == v2) then
		print("ERROR!! TEST FAILED " .. testname .. " -> " .. tostring(v1) .. " != ".. tostring(v2))
		allok = false
	end
end

function asserteq(v1, v2)
	if (v1 ~= v2) then
		print("ERROR!! TEST FAILED " .. testname .. " -> " .. tostring(v1) .. " == ".. tostring(v2))
		allok = false
	end
end

function assertArray(v)
	asserteq(v, expected[expindex])
	expindex = expindex + 1
end

function assertArrayBegin(tx)
	expected = tx
	expindex = 1
end

function assertArrayEnd()
	asserteq(#expected, expindex - 1)
end

function autoexec()
	print("===============================================================")

	testname = "Test #" ..  1
	assertArrayBegin(array)
	grimq.from(array)
		:foreach(assertArray)
	assertArrayEnd()

	testname = "Test #" ..  2
	assertArrayBegin({4, 5, 9})
		grimq.from(array)
			:select(function(v) return #v; end)
			:foreach(assertArray)
	assertArrayEnd()

	testname = "Test #" ..  3
	assertArrayBegin({"ciao", 4, "hello", 5, "au revoir", 9})
	grimq.from(array)
		:selectMany(function(v) return { v, #v }; end)
			:foreach(assertArray)
	assertArrayEnd()

	testname = "Test #" ..  4
	assertArrayBegin({ "HELLO", "AU REVOIR"})
		grimq.from(array)
			:where(function(v) return #v >= 5; end)
			:select(function(v) return string.upper(v); end)
			:foreach(assertArray)
	assertArrayEnd()

	testname = "Test #" ..  5
	assertArrayBegin({ "ciao", "au revoir"})
		grimq.from(array)
			:whereIndex(function (i, v) return ((i % 2)~=0); end)
			:foreach(assertArray)
	assertArrayEnd()

	testname = "Test #" ..  5
	assertArrayBegin({ "ciao", "hello"})
	grimq.from(array)
		:take(2)
			:foreach(assertArray)
	assertArrayEnd()

	testname = "Test #" ..  6
	assertArrayBegin({ "ciao", "hello", "au revoir", "arrivederci", "goodbye", "bonjour"})
		grimq.from(array)
			:concat(grimq.from(array2))
			:foreach(assertArray)
	assertArrayEnd()

	testname = "Test #" ..  7
	assertArrayBegin({ "ciao/arrivederci", "hello/goodbye", "au revoir/bonjour"})
		grimq.from(array)
			:zip(grimq.from(array2), function(a,b) return a .. "/" .. b; end)
			:foreach(assertArray)
	assertArrayEnd()

	testname = "Test #" ..  8
	assertneq(grimq.from(array):random(), nil)

	testname = "Test #" ..  9
	asserteq(grimq.from(array):first(), "ciao")

	testname = "Test #" ..  10
	asserteq(grimq.from(array):last(), "au revoir")

	testname = "Test #" ..  11
	asserteq(grimq.from(array):any(function(v) return #v > 5; end), true)

	testname = "Test #" ..  12
	asserteq(grimq.from(array):all(function(v) return #v > 5; end), false)

	testname = "Test #" ..  13
	asserteq(grimq.from(array):any(function(v) return #v > 15; end), false)

	testname = "Test #" ..  14
	asserteq(grimq.from(array):contains("hello"), true)

	testname = "Test #" ..  15
	asserteq(grimq.from(array):contains("qweqhello"), false)

	testname = "Test #" ..  16
	asserteq(grimq.from(array):sum(function(e) return #e; end), 18)

	testname = "Test #" ..  17
	asserteq(grimq.from(array):average(function(e) return #e; end), 6)

	testname = "Test #" ..  18
	assertArrayBegin({ "ciao", "hello", "au revoir"})
		grimq.from({ "ciao", "ciao", "ciao", "hello", "au revoir", "ciao", "hello", "au revoir"})
			:distinct()
			:foreach(assertArray)
	assertArrayEnd()

	testname = "Test #" ..  19
	assertArrayBegin({ "ciao", "yeah", "hello", "au revoir"})
		grimq.from({ "ciao", "ciao", "yeah"})
			:union(grimq.from(array))
			:foreach(assertArray)
	assertArrayEnd()

	testname = "Test #" ..  20
	assertArrayBegin({ "yeah"})
		grimq.from({ "ciao", "yeah", "hello", "au revoir"})
			:except(grimq.from(array))
			:foreach(assertArray)
	assertArrayEnd()

	testname = "Test #" ..  21
	assertArrayBegin({ "ciao", "hello"})
		grimq.from({ "ciao", "yeah", "hello", })
			:intersection(array)
			:foreach(assertArray)
	assertArrayEnd()

	testname = "Test #" ..  22
	assertArrayBegin({ "ciao" })
		grimq.from(array3)
			:where("lang", "ita")
			:select("say")
			:foreach(assertArray)
	assertArrayEnd()
	
	if (allok) then
		print("ALL TESTS PASSED!")
	end

end













