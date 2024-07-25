--[[
 .____                  ________ ___.    _____                           __                
 |    |    __ _______   \_____  \\_ |___/ ____\_ __  ______ ____ _____ _/  |_  ___________ 
 |    |   |  |  \__  \   /   |   \| __ \   __\  |  \/  ___// ___\\__  \\   __\/  _ \_  __ \
 |    |___|  |  // __ \_/    |    \ \_\ \  | |  |  /\___ \\  \___ / __ \|  | (  <_> )  | \/
 |_______ \____/(____  /\_______  /___  /__| |____//____  >\___  >____  /__|  \____/|__|   
         \/          \/         \/    \/                \/     \/     \/                   
          \_Welcome to LuaObfuscator.com   (Alpha 0.10.6) ~  Much Love, Ferib 

]]--

local StrToNumber = tonumber;
local Byte = string.byte;
local Char = string.char;
local Sub = string.sub;
local Subg = string.gsub;
local Rep = string.rep;
local Concat = table.concat;
local Insert = table.insert;
local LDExp = math.ldexp;
local GetFEnv = getfenv or function()
	return _ENV;
end;
local Setmetatable = setmetatable;
local PCall = pcall;
local Select = select;
local Unpack = unpack or table.unpack;
local ToNumber = tonumber;
local function VMCall(ByteString, vmenv, ...)
	local DIP = 1;
	local repeatNext;
	ByteString = Subg(Sub(ByteString, 5), "..", function(byte)
		if (Byte(byte, 2) == 79) then
			repeatNext = StrToNumber(Sub(byte, 1, 1));
			return "";
		else
			local FlatIdent_98E39 = 0;
			local a;
			while true do
				if (0 == FlatIdent_98E39) then
					a = Char(StrToNumber(byte, 16));
					if repeatNext then
						local b = Rep(a, repeatNext);
						repeatNext = nil;
						return b;
					else
						return a;
					end
					break;
				end
			end
		end
	end);
	local function gBit(Bit, Start, End)
		if End then
			local FlatIdent_8E3FD = 0;
			local Res;
			while true do
				if (FlatIdent_8E3FD == 0) then
					Res = (Bit / (2 ^ (Start - 1))) % (2 ^ (((End - 1) - (Start - 1)) + 1));
					return Res - (Res % 1);
				end
			end
		else
			local FlatIdent_12703 = 0;
			local Plc;
			while true do
				if (FlatIdent_12703 == 0) then
					Plc = 2 ^ (Start - 1);
					return (((Bit % (Plc + Plc)) >= Plc) and 1) or 0;
				end
			end
		end
	end
	local function gBits8()
		local a = Byte(ByteString, DIP, DIP);
		DIP = DIP + 1;
		return a;
	end
	local function gBits16()
		local a, b = Byte(ByteString, DIP, DIP + 2);
		DIP = DIP + 2;
		return (b * 256) + a;
	end
	local function gBits32()
		local FlatIdent_2BD95 = 0;
		local a;
		local b;
		local c;
		local d;
		while true do
			if (FlatIdent_2BD95 == 1) then
				return (d * 16777216) + (c * 65536) + (b * 256) + a;
			end
			if (FlatIdent_2BD95 == 0) then
				a, b, c, d = Byte(ByteString, DIP, DIP + 3);
				DIP = DIP + 4;
				FlatIdent_2BD95 = 1;
			end
		end
	end
	local function gFloat()
		local Left = gBits32();
		local Right = gBits32();
		local IsNormal = 1;
		local Mantissa = (gBit(Right, 1, 20) * (2 ^ 32)) + Left;
		local Exponent = gBit(Right, 21, 31);
		local Sign = ((gBit(Right, 32) == 1) and -1) or 1;
		if (Exponent == 0) then
			if (Mantissa == 0) then
				return Sign * 0;
			else
				local FlatIdent_D07E = 0;
				while true do
					if (FlatIdent_D07E == 0) then
						Exponent = 1;
						IsNormal = 0;
						break;
					end
				end
			end
		elseif (Exponent == 2047) then
			return ((Mantissa == 0) and (Sign * (1 / 0))) or (Sign * NaN);
		end
		return LDExp(Sign, Exponent - 1023) * (IsNormal + (Mantissa / (2 ^ 52)));
	end
	local function gString(Len)
		local Str;
		if not Len then
			Len = gBits32();
			if (Len == 0) then
				return "";
			end
		end
		Str = Sub(ByteString, DIP, (DIP + Len) - 1);
		DIP = DIP + Len;
		local FStr = {};
		for Idx = 1, #Str do
			FStr[Idx] = Char(Byte(Sub(Str, Idx, Idx)));
		end
		return Concat(FStr);
	end
	local gInt = gBits32;
	local function _R(...)
		return {...}, Select("#", ...);
	end
	local function Deserialize()
		local Instrs = {};
		local Functions = {};
		local Lines = {};
		local Chunk = {Instrs,Functions,nil,Lines};
		local ConstCount = gBits32();
		local Consts = {};
		for Idx = 1, ConstCount do
			local Type = gBits8();
			local Cons;
			if (Type == 1) then
				Cons = gBits8() ~= 0;
			elseif (Type == 2) then
				Cons = gFloat();
			elseif (Type == 3) then
				Cons = gString();
			end
			Consts[Idx] = Cons;
		end
		Chunk[3] = gBits8();
		for Idx = 1, gBits32() do
			local FlatIdent_60EA1 = 0;
			local Descriptor;
			while true do
				if (FlatIdent_60EA1 == 0) then
					Descriptor = gBits8();
					if (gBit(Descriptor, 1, 1) == 0) then
						local Type = gBit(Descriptor, 2, 3);
						local Mask = gBit(Descriptor, 4, 6);
						local Inst = {gBits16(),gBits16(),nil,nil};
						if (Type == 0) then
							local FlatIdent_37E3 = 0;
							while true do
								if (FlatIdent_37E3 == 0) then
									Inst[3] = gBits16();
									Inst[4] = gBits16();
									break;
								end
							end
						elseif (Type == 1) then
							Inst[3] = gBits32();
						elseif (Type == 2) then
							Inst[3] = gBits32() - (2 ^ 16);
						elseif (Type == 3) then
							local FlatIdent_31A5A = 0;
							while true do
								if (FlatIdent_31A5A == 0) then
									Inst[3] = gBits32() - (2 ^ 16);
									Inst[4] = gBits16();
									break;
								end
							end
						end
						if (gBit(Mask, 1, 1) == 1) then
							Inst[2] = Consts[Inst[2]];
						end
						if (gBit(Mask, 2, 2) == 1) then
							Inst[3] = Consts[Inst[3]];
						end
						if (gBit(Mask, 3, 3) == 1) then
							Inst[4] = Consts[Inst[4]];
						end
						Instrs[Idx] = Inst;
					end
					break;
				end
			end
		end
		for Idx = 1, gBits32() do
			Functions[Idx - 1] = Deserialize();
		end
		return Chunk;
	end
	local function Wrap(Chunk, Upvalues, Env)
		local Instr = Chunk[1];
		local Proto = Chunk[2];
		local Params = Chunk[3];
		return function(...)
			local Instr = Instr;
			local Proto = Proto;
			local Params = Params;
			local _R = _R;
			local VIP = 1;
			local Top = -1;
			local Vararg = {};
			local Args = {...};
			local PCount = Select("#", ...) - 1;
			local Lupvals = {};
			local Stk = {};
			for Idx = 0, PCount do
				if (Idx >= Params) then
					Vararg[Idx - Params] = Args[Idx + 1];
				else
					Stk[Idx] = Args[Idx + 1];
				end
			end
			local Varargsz = (PCount - Params) + 1;
			local Inst;
			local Enum;
			while true do
				local FlatIdent_5ED46 = 0;
				while true do
					if (FlatIdent_5ED46 == 1) then
						if (Enum <= 33) then
							if (Enum <= 16) then
								if (Enum <= 7) then
									if (Enum <= 3) then
										if (Enum <= 1) then
											if (Enum > 0) then
												local B;
												local A;
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = {};
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
											else
												local FlatIdent_51F42 = 0;
												while true do
													if (FlatIdent_51F42 == 9) then
														Stk[Inst[2]] = Inst[3];
														break;
													end
													if (FlatIdent_51F42 == 0) then
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_51F42 = 1;
													end
													if (FlatIdent_51F42 == 7) then
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_51F42 = 8;
													end
													if (FlatIdent_51F42 == 4) then
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_51F42 = 5;
													end
													if (3 == FlatIdent_51F42) then
														Stk[Inst[2]][Inst[3]] = Inst[4];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_51F42 = 4;
													end
													if (FlatIdent_51F42 == 1) then
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_51F42 = 2;
													end
													if (FlatIdent_51F42 == 6) then
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_51F42 = 7;
													end
													if (5 == FlatIdent_51F42) then
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_51F42 = 6;
													end
													if (FlatIdent_51F42 == 8) then
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_51F42 = 9;
													end
													if (FlatIdent_51F42 == 2) then
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_51F42 = 3;
													end
												end
											end
										elseif (Enum > 2) then
											local FlatIdent_4D23E = 0;
											local B;
											local A;
											while true do
												if (FlatIdent_4D23E == 5) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Stk[A + 1]);
													break;
												end
												if (FlatIdent_4D23E == 2) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_4D23E = 3;
												end
												if (FlatIdent_4D23E == 0) then
													B = nil;
													A = nil;
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													FlatIdent_4D23E = 1;
												end
												if (FlatIdent_4D23E == 3) then
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_4D23E = 4;
												end
												if (FlatIdent_4D23E == 1) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													FlatIdent_4D23E = 2;
												end
												if (FlatIdent_4D23E == 4) then
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_4D23E = 5;
												end
											end
										else
											Stk[Inst[2]] = Env[Inst[3]];
										end
									elseif (Enum <= 5) then
										if (Enum == 4) then
											local FlatIdent_53252 = 0;
											local A;
											while true do
												if (FlatIdent_53252 == 4) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_53252 = 5;
												end
												if (FlatIdent_53252 == 7) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													FlatIdent_53252 = 8;
												end
												if (FlatIdent_53252 == 9) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													break;
												end
												if (FlatIdent_53252 == 2) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													FlatIdent_53252 = 3;
												end
												if (FlatIdent_53252 == 3) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_53252 = 4;
												end
												if (FlatIdent_53252 == 0) then
													A = nil;
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													FlatIdent_53252 = 1;
												end
												if (FlatIdent_53252 == 1) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_53252 = 2;
												end
												if (FlatIdent_53252 == 5) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_53252 = 6;
												end
												if (FlatIdent_53252 == 6) then
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													FlatIdent_53252 = 7;
												end
												if (FlatIdent_53252 == 8) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													FlatIdent_53252 = 9;
												end
											end
										else
											local FlatIdent_1B1BA = 0;
											local A;
											while true do
												if (8 == FlatIdent_1B1BA) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_1B1BA = 9;
												end
												if (FlatIdent_1B1BA == 3) then
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													FlatIdent_1B1BA = 4;
												end
												if (FlatIdent_1B1BA == 0) then
													A = nil;
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_1B1BA = 1;
												end
												if (FlatIdent_1B1BA == 9) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													break;
												end
												if (FlatIdent_1B1BA == 7) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_1B1BA = 8;
												end
												if (FlatIdent_1B1BA == 5) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													FlatIdent_1B1BA = 6;
												end
												if (FlatIdent_1B1BA == 1) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_1B1BA = 2;
												end
												if (6 == FlatIdent_1B1BA) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													FlatIdent_1B1BA = 7;
												end
												if (FlatIdent_1B1BA == 4) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													FlatIdent_1B1BA = 5;
												end
												if (FlatIdent_1B1BA == 2) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_1B1BA = 3;
												end
											end
										end
									elseif (Enum > 6) then
										Stk[Inst[2]] = Upvalues[Inst[3]];
									else
										local FlatIdent_D895 = 0;
										while true do
											if (FlatIdent_D895 == 5) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_D895 = 6;
											end
											if (FlatIdent_D895 == 1) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												FlatIdent_D895 = 2;
											end
											if (4 == FlatIdent_D895) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_D895 = 5;
											end
											if (FlatIdent_D895 == 0) then
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												FlatIdent_D895 = 1;
											end
											if (FlatIdent_D895 == 3) then
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												FlatIdent_D895 = 4;
											end
											if (FlatIdent_D895 == 6) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												break;
											end
											if (FlatIdent_D895 == 2) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_D895 = 3;
											end
										end
									end
								elseif (Enum <= 11) then
									if (Enum <= 9) then
										if (Enum == 8) then
											Stk[Inst[2]] = Stk[Inst[3]];
										else
											local FlatIdent_8D1A5 = 0;
											local A;
											while true do
												if (0 == FlatIdent_8D1A5) then
													A = Inst[2];
													Stk[A](Stk[A + 1]);
													break;
												end
											end
										end
									elseif (Enum == 10) then
										local FlatIdent_630B0 = 0;
										local A;
										while true do
											if (FlatIdent_630B0 == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Stk[A + 1]);
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_630B0 = 4;
											end
											if (FlatIdent_630B0 == 5) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												break;
											end
											if (FlatIdent_630B0 == 2) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_630B0 = 3;
											end
											if (FlatIdent_630B0 == 1) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												FlatIdent_630B0 = 2;
											end
											if (FlatIdent_630B0 == 0) then
												A = nil;
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Stk[A + 1]);
												FlatIdent_630B0 = 1;
											end
											if (FlatIdent_630B0 == 4) then
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_630B0 = 5;
											end
										end
									else
										local FlatIdent_97F0B = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_97F0B == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_97F0B = 4;
											end
											if (FlatIdent_97F0B == 5) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_97F0B = 6;
											end
											if (FlatIdent_97F0B == 2) then
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												FlatIdent_97F0B = 3;
											end
											if (6 == FlatIdent_97F0B) then
												Stk[Inst[2]] = {};
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												break;
											end
											if (FlatIdent_97F0B == 4) then
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												FlatIdent_97F0B = 5;
											end
											if (FlatIdent_97F0B == 0) then
												B = nil;
												A = nil;
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_97F0B = 1;
											end
											if (FlatIdent_97F0B == 1) then
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												FlatIdent_97F0B = 2;
											end
										end
									end
								elseif (Enum <= 13) then
									if (Enum > 12) then
										local B;
										local A;
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										VIP = Inst[3];
									else
										local A;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
									end
								elseif (Enum <= 14) then
									local FlatIdent_69531 = 0;
									local A;
									while true do
										if (FlatIdent_69531 == 0) then
											A = Inst[2];
											Stk[A] = Stk[A](Stk[A + 1]);
											break;
										end
									end
								elseif (Enum == 15) then
									local A;
									A = Inst[2];
									Stk[A] = Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								else
									local A;
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
								end
							elseif (Enum <= 24) then
								if (Enum <= 20) then
									if (Enum <= 18) then
										if (Enum > 17) then
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
										else
											local A;
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
										end
									elseif (Enum == 19) then
										local FlatIdent_6134A = 0;
										local Edx;
										local Results;
										local Limit;
										local B;
										local A;
										while true do
											if (FlatIdent_6134A == 5) then
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_6134A = 6;
											end
											if (FlatIdent_6134A == 0) then
												Edx = nil;
												Results, Limit = nil;
												B = nil;
												A = nil;
												Stk[Inst[2]] = Inst[3];
												FlatIdent_6134A = 1;
											end
											if (FlatIdent_6134A == 2) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_6134A = 3;
											end
											if (6 == FlatIdent_6134A) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3] ~= 0;
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_6134A = 7;
											end
											if (FlatIdent_6134A == 4) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												FlatIdent_6134A = 5;
											end
											if (7 == FlatIdent_6134A) then
												Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
												Top = (Limit + A) - 1;
												Edx = 0;
												for Idx = A, Top do
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
												end
												break;
											end
											if (3 == FlatIdent_6134A) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												FlatIdent_6134A = 4;
											end
											if (FlatIdent_6134A == 1) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_6134A = 2;
											end
										end
									else
										local FlatIdent_8B523 = 0;
										local A;
										local Cls;
										while true do
											if (FlatIdent_8B523 == 1) then
												for Idx = 1, #Lupvals do
													local List = Lupvals[Idx];
													for Idz = 0, #List do
														local Upv = List[Idz];
														local NStk = Upv[1];
														local DIP = Upv[2];
														if ((NStk == Stk) and (DIP >= A)) then
															local FlatIdent_9917B = 0;
															while true do
																if (FlatIdent_9917B == 0) then
																	Cls[DIP] = NStk[DIP];
																	Upv[1] = Cls;
																	break;
																end
															end
														end
													end
												end
												break;
											end
											if (FlatIdent_8B523 == 0) then
												A = Inst[2];
												Cls = {};
												FlatIdent_8B523 = 1;
											end
										end
									end
								elseif (Enum <= 22) then
									if (Enum > 21) then
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									else
										local FlatIdent_61EE = 0;
										local A;
										while true do
											if (FlatIdent_61EE == 0) then
												A = nil;
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_61EE = 1;
											end
											if (FlatIdent_61EE == 2) then
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												FlatIdent_61EE = 3;
											end
											if (3 == FlatIdent_61EE) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												break;
											end
											if (FlatIdent_61EE == 1) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_61EE = 2;
											end
										end
									end
								elseif (Enum == 23) then
									local FlatIdent_5998C = 0;
									local A;
									local Results;
									local Limit;
									local Edx;
									while true do
										if (FlatIdent_5998C == 0) then
											A = Inst[2];
											Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
											FlatIdent_5998C = 1;
										end
										if (FlatIdent_5998C == 2) then
											for Idx = A, Top do
												local FlatIdent_4D434 = 0;
												while true do
													if (FlatIdent_4D434 == 0) then
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
														break;
													end
												end
											end
											break;
										end
										if (1 == FlatIdent_5998C) then
											Top = (Limit + A) - 1;
											Edx = 0;
											FlatIdent_5998C = 2;
										end
									end
								else
									local FlatIdent_45D37 = 0;
									local A;
									local B;
									while true do
										if (FlatIdent_45D37 == 1) then
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											break;
										end
										if (FlatIdent_45D37 == 0) then
											A = Inst[2];
											B = Stk[Inst[3]];
											FlatIdent_45D37 = 1;
										end
									end
								end
							elseif (Enum <= 28) then
								if (Enum <= 26) then
									if (Enum > 25) then
										do
											return;
										end
									else
										local FlatIdent_90A41 = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_90A41 == 3) then
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_90A41 = 4;
											end
											if (FlatIdent_90A41 == 9) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												break;
											end
											if (FlatIdent_90A41 == 0) then
												B = nil;
												A = nil;
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_90A41 = 1;
											end
											if (FlatIdent_90A41 == 6) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_90A41 = 7;
											end
											if (FlatIdent_90A41 == 5) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_90A41 = 6;
											end
											if (FlatIdent_90A41 == 7) then
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												FlatIdent_90A41 = 8;
											end
											if (FlatIdent_90A41 == 2) then
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_90A41 = 3;
											end
											if (FlatIdent_90A41 == 8) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												FlatIdent_90A41 = 9;
											end
											if (FlatIdent_90A41 == 1) then
												Stk[A](Stk[A + 1]);
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_90A41 = 2;
											end
											if (FlatIdent_90A41 == 4) then
												Stk[Inst[2]] = {};
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_90A41 = 5;
											end
										end
									end
								elseif (Enum > 27) then
									if Stk[Inst[2]] then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								else
									local B;
									local A;
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									VIP = Inst[3];
								end
							elseif (Enum <= 30) then
								if (Enum > 29) then
									local FlatIdent_5431F = 0;
									local A;
									while true do
										if (FlatIdent_5431F == 0) then
											A = nil;
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_5431F = 1;
										end
										if (FlatIdent_5431F == 5) then
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											FlatIdent_5431F = 6;
										end
										if (2 == FlatIdent_5431F) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_5431F = 3;
										end
										if (FlatIdent_5431F == 6) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											do
												return;
											end
											break;
										end
										if (FlatIdent_5431F == 3) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_5431F = 4;
										end
										if (4 == FlatIdent_5431F) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_5431F = 5;
										end
										if (FlatIdent_5431F == 1) then
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_5431F = 2;
										end
									end
								else
									local B;
									local A;
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									VIP = Inst[3];
								end
							elseif (Enum <= 31) then
								local FlatIdent_8E53E = 0;
								local A;
								while true do
									if (FlatIdent_8E53E == 4) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										FlatIdent_8E53E = 5;
									end
									if (FlatIdent_8E53E == 0) then
										A = nil;
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										FlatIdent_8E53E = 1;
									end
									if (FlatIdent_8E53E == 3) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										FlatIdent_8E53E = 4;
									end
									if (FlatIdent_8E53E == 2) then
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										FlatIdent_8E53E = 3;
									end
									if (FlatIdent_8E53E == 7) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_8E53E = 8;
									end
									if (FlatIdent_8E53E == 8) then
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										FlatIdent_8E53E = 9;
									end
									if (FlatIdent_8E53E == 9) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										break;
									end
									if (FlatIdent_8E53E == 5) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_8E53E = 6;
									end
									if (FlatIdent_8E53E == 6) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_8E53E = 7;
									end
									if (FlatIdent_8E53E == 1) then
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										FlatIdent_8E53E = 2;
									end
								end
							elseif (Enum == 32) then
								Stk[Inst[2]]();
							else
								local B;
								local A;
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
							end
						elseif (Enum <= 50) then
							if (Enum <= 41) then
								if (Enum <= 37) then
									if (Enum <= 35) then
										if (Enum > 34) then
											local FlatIdent_28855 = 0;
											local A;
											while true do
												if (FlatIdent_28855 == 2) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													FlatIdent_28855 = 3;
												end
												if (FlatIdent_28855 == 4) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
													FlatIdent_28855 = 5;
												end
												if (FlatIdent_28855 == 1) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													FlatIdent_28855 = 2;
												end
												if (FlatIdent_28855 == 5) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													FlatIdent_28855 = 6;
												end
												if (0 == FlatIdent_28855) then
													A = nil;
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													FlatIdent_28855 = 1;
												end
												if (8 == FlatIdent_28855) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													FlatIdent_28855 = 9;
												end
												if (FlatIdent_28855 == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													FlatIdent_28855 = 4;
												end
												if (FlatIdent_28855 == 9) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													break;
												end
												if (7 == FlatIdent_28855) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													FlatIdent_28855 = 8;
												end
												if (FlatIdent_28855 == 6) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													FlatIdent_28855 = 7;
												end
											end
										else
											local FlatIdent_21811 = 0;
											local NewProto;
											local NewUvals;
											local Indexes;
											while true do
												if (FlatIdent_21811 == 1) then
													Indexes = {};
													NewUvals = Setmetatable({}, {__index=function(_, Key)
														local Val = Indexes[Key];
														return Val[1][Val[2]];
													end,__newindex=function(_, Key, Value)
														local Val = Indexes[Key];
														Val[1][Val[2]] = Value;
													end});
													FlatIdent_21811 = 2;
												end
												if (FlatIdent_21811 == 2) then
													for Idx = 1, Inst[4] do
														local FlatIdent_93E71 = 0;
														local Mvm;
														while true do
															if (0 == FlatIdent_93E71) then
																VIP = VIP + 1;
																Mvm = Instr[VIP];
																FlatIdent_93E71 = 1;
															end
															if (FlatIdent_93E71 == 1) then
																if (Mvm[1] == 8) then
																	Indexes[Idx - 1] = {Stk,Mvm[3]};
																else
																	Indexes[Idx - 1] = {Upvalues,Mvm[3]};
																end
																Lupvals[#Lupvals + 1] = Indexes;
																break;
															end
														end
													end
													Stk[Inst[2]] = Wrap(NewProto, NewUvals, Env);
													break;
												end
												if (FlatIdent_21811 == 0) then
													NewProto = Proto[Inst[3]];
													NewUvals = nil;
													FlatIdent_21811 = 1;
												end
											end
										end
									elseif (Enum == 36) then
										local FlatIdent_8FBAE = 0;
										local A;
										while true do
											if (FlatIdent_8FBAE == 3) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_8FBAE = 4;
											end
											if (FlatIdent_8FBAE == 5) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												FlatIdent_8FBAE = 6;
											end
											if (4 == FlatIdent_8FBAE) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												FlatIdent_8FBAE = 5;
											end
											if (FlatIdent_8FBAE == 6) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												break;
											end
											if (FlatIdent_8FBAE == 0) then
												A = nil;
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_8FBAE = 1;
											end
											if (FlatIdent_8FBAE == 1) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_8FBAE = 2;
											end
											if (FlatIdent_8FBAE == 2) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_8FBAE = 3;
											end
										end
									else
										local FlatIdent_829F9 = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_829F9 == 7) then
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A](Stk[A + 1]);
												FlatIdent_829F9 = 8;
											end
											if (FlatIdent_829F9 == 2) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_829F9 = 3;
											end
											if (FlatIdent_829F9 == 1) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												FlatIdent_829F9 = 2;
											end
											if (FlatIdent_829F9 == 3) then
												Stk[Inst[2]] = {};
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_829F9 = 4;
											end
											if (FlatIdent_829F9 == 0) then
												B = nil;
												A = nil;
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A](Stk[A + 1]);
												VIP = VIP + 1;
												FlatIdent_829F9 = 1;
											end
											if (6 == FlatIdent_829F9) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_829F9 = 7;
											end
											if (FlatIdent_829F9 == 8) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												break;
											end
											if (FlatIdent_829F9 == 5) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												FlatIdent_829F9 = 6;
											end
											if (FlatIdent_829F9 == 4) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_829F9 = 5;
											end
										end
									end
								elseif (Enum <= 39) then
									if (Enum > 38) then
										Stk[Inst[2]] = {};
									else
										local FlatIdent_33DE6 = 0;
										local A;
										while true do
											if (FlatIdent_33DE6 == 5) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = {};
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												FlatIdent_33DE6 = 6;
											end
											if (FlatIdent_33DE6 == 4) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												FlatIdent_33DE6 = 5;
											end
											if (FlatIdent_33DE6 == 0) then
												A = nil;
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_33DE6 = 1;
											end
											if (2 == FlatIdent_33DE6) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_33DE6 = 3;
											end
											if (3 == FlatIdent_33DE6) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_33DE6 = 4;
											end
											if (FlatIdent_33DE6 == 1) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_33DE6 = 2;
											end
											if (FlatIdent_33DE6 == 6) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												break;
											end
										end
									end
								elseif (Enum == 40) then
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
								else
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								end
							elseif (Enum <= 45) then
								if (Enum <= 43) then
									if (Enum > 42) then
										if (Stk[Inst[2]] == Stk[Inst[4]]) then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									else
										local A;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
									end
								elseif (Enum == 44) then
									local FlatIdent_92514 = 0;
									local A;
									while true do
										if (6 == FlatIdent_92514) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											for Idx = Inst[2], Inst[3] do
												Stk[Idx] = nil;
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_92514 = 7;
										end
										if (FlatIdent_92514 == 3) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_92514 = 4;
										end
										if (FlatIdent_92514 == 1) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_92514 = 2;
										end
										if (FlatIdent_92514 == 7) then
											Stk[Inst[2]] = Inst[3];
											break;
										end
										if (FlatIdent_92514 == 4) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_92514 = 5;
										end
										if (FlatIdent_92514 == 5) then
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											FlatIdent_92514 = 6;
										end
										if (FlatIdent_92514 == 2) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_92514 = 3;
										end
										if (FlatIdent_92514 == 0) then
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_92514 = 1;
										end
									end
								else
									local A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
								end
							elseif (Enum <= 47) then
								if (Enum > 46) then
									local A;
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
								else
									local A;
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
								end
							elseif (Enum <= 48) then
								local FlatIdent_A446 = 0;
								local A;
								while true do
									if (FlatIdent_A446 == 1) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										FlatIdent_A446 = 2;
									end
									if (FlatIdent_A446 == 9) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										break;
									end
									if (FlatIdent_A446 == 6) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										FlatIdent_A446 = 7;
									end
									if (8 == FlatIdent_A446) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										FlatIdent_A446 = 9;
									end
									if (FlatIdent_A446 == 4) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_A446 = 5;
									end
									if (0 == FlatIdent_A446) then
										A = nil;
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										FlatIdent_A446 = 1;
									end
									if (FlatIdent_A446 == 5) then
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										FlatIdent_A446 = 6;
									end
									if (FlatIdent_A446 == 7) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										FlatIdent_A446 = 8;
									end
									if (FlatIdent_A446 == 2) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_A446 = 3;
									end
									if (FlatIdent_A446 == 3) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_A446 = 4;
									end
								end
							elseif (Enum == 49) then
								Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
							else
								VIP = Inst[3];
							end
						elseif (Enum <= 58) then
							if (Enum <= 54) then
								if (Enum <= 52) then
									if (Enum > 51) then
										if (Stk[Inst[2]] == Inst[4]) then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									else
										local FlatIdent_15034 = 0;
										local B;
										local A;
										while true do
											if (1 == FlatIdent_15034) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												FlatIdent_15034 = 2;
											end
											if (FlatIdent_15034 == 6) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												for Idx = Inst[2], Inst[3] do
													Stk[Idx] = nil;
												end
												break;
											end
											if (0 == FlatIdent_15034) then
												B = nil;
												A = nil;
												A = Inst[2];
												Stk[A](Stk[A + 1]);
												FlatIdent_15034 = 1;
											end
											if (FlatIdent_15034 == 2) then
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_15034 = 3;
											end
											if (3 == FlatIdent_15034) then
												A = Inst[2];
												Stk[A](Stk[A + 1]);
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_15034 = 4;
											end
											if (4 == FlatIdent_15034) then
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												FlatIdent_15034 = 5;
											end
											if (FlatIdent_15034 == 5) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A](Stk[A + 1]);
												FlatIdent_15034 = 6;
											end
										end
									end
								elseif (Enum > 53) then
									local FlatIdent_74B46 = 0;
									local B;
									local A;
									while true do
										if (FlatIdent_74B46 == 0) then
											B = nil;
											A = nil;
											A = Inst[2];
											B = Stk[Inst[3]];
											FlatIdent_74B46 = 1;
										end
										if (FlatIdent_74B46 == 4) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											break;
										end
										if (FlatIdent_74B46 == 1) then
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_74B46 = 2;
										end
										if (FlatIdent_74B46 == 3) then
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											FlatIdent_74B46 = 4;
										end
										if (FlatIdent_74B46 == 2) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_74B46 = 3;
										end
									end
								else
									for Idx = Inst[2], Inst[3] do
										Stk[Idx] = nil;
									end
								end
							elseif (Enum <= 56) then
								if (Enum > 55) then
									local A;
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
								else
									local FlatIdent_4087C = 0;
									local A;
									while true do
										if (FlatIdent_4087C == 2) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_4087C = 3;
										end
										if (FlatIdent_4087C == 0) then
											A = nil;
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_4087C = 1;
										end
										if (FlatIdent_4087C == 3) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_4087C = 4;
										end
										if (FlatIdent_4087C == 6) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_4087C = 7;
										end
										if (FlatIdent_4087C == 5) then
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											FlatIdent_4087C = 6;
										end
										if (FlatIdent_4087C == 7) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											break;
										end
										if (FlatIdent_4087C == 4) then
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_4087C = 5;
										end
										if (FlatIdent_4087C == 1) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_4087C = 2;
										end
									end
								end
							elseif (Enum == 57) then
								local FlatIdent_FBDE = 0;
								local A;
								while true do
									if (FlatIdent_FBDE == 5) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										FlatIdent_FBDE = 6;
									end
									if (FlatIdent_FBDE == 1) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_FBDE = 2;
									end
									if (FlatIdent_FBDE == 7) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										FlatIdent_FBDE = 8;
									end
									if (FlatIdent_FBDE == 6) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										FlatIdent_FBDE = 7;
									end
									if (FlatIdent_FBDE == 0) then
										A = nil;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										FlatIdent_FBDE = 1;
									end
									if (FlatIdent_FBDE == 2) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_FBDE = 3;
									end
									if (FlatIdent_FBDE == 4) then
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										FlatIdent_FBDE = 5;
									end
									if (FlatIdent_FBDE == 9) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										break;
									end
									if (FlatIdent_FBDE == 3) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_FBDE = 4;
									end
									if (FlatIdent_FBDE == 8) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										FlatIdent_FBDE = 9;
									end
								end
							elseif (Inst[2] == Stk[Inst[4]]) then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						elseif (Enum <= 62) then
							if (Enum <= 60) then
								if (Enum > 59) then
									local A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
								else
									local FlatIdent_1CE81 = 0;
									local A;
									while true do
										if (FlatIdent_1CE81 == 5) then
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											FlatIdent_1CE81 = 6;
										end
										if (FlatIdent_1CE81 == 0) then
											A = nil;
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_1CE81 = 1;
										end
										if (FlatIdent_1CE81 == 4) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_1CE81 = 5;
										end
										if (FlatIdent_1CE81 == 3) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_1CE81 = 4;
										end
										if (FlatIdent_1CE81 == 1) then
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_1CE81 = 2;
										end
										if (FlatIdent_1CE81 == 2) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_1CE81 = 3;
										end
										if (FlatIdent_1CE81 == 6) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											do
												return;
											end
											break;
										end
									end
								end
							elseif (Enum > 61) then
								local FlatIdent_197AE = 0;
								local A;
								while true do
									if (FlatIdent_197AE == 2) then
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_197AE = 3;
									end
									if (3 == FlatIdent_197AE) then
										Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										FlatIdent_197AE = 4;
									end
									if (FlatIdent_197AE == 4) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										VIP = Inst[3];
										break;
									end
									if (FlatIdent_197AE == 0) then
										A = nil;
										A = Inst[2];
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										FlatIdent_197AE = 1;
									end
									if (FlatIdent_197AE == 1) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_197AE = 2;
									end
								end
							else
								Stk[Inst[2]] = Inst[3];
							end
						elseif (Enum <= 64) then
							if (Enum > 63) then
								local A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
							else
								local A;
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
							end
						elseif (Enum <= 65) then
							Stk[Inst[2]] = Inst[3] ~= 0;
						elseif (Enum == 66) then
							Stk[Inst[2]][Inst[3]] = Inst[4];
						else
							local FlatIdent_86634 = 0;
							local B;
							local A;
							while true do
								if (FlatIdent_86634 == 9) then
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									FlatIdent_86634 = 10;
								end
								if (FlatIdent_86634 == 6) then
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									FlatIdent_86634 = 7;
								end
								if (FlatIdent_86634 == 7) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									FlatIdent_86634 = 8;
								end
								if (FlatIdent_86634 == 0) then
									B = nil;
									A = nil;
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									FlatIdent_86634 = 1;
								end
								if (FlatIdent_86634 == 8) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_86634 = 9;
								end
								if (FlatIdent_86634 == 3) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_86634 = 4;
								end
								if (FlatIdent_86634 == 5) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_86634 = 6;
								end
								if (11 == FlatIdent_86634) then
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									VIP = Inst[3];
									break;
								end
								if (4 == FlatIdent_86634) then
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									FlatIdent_86634 = 5;
								end
								if (FlatIdent_86634 == 1) then
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									FlatIdent_86634 = 2;
								end
								if (FlatIdent_86634 == 2) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = {};
									FlatIdent_86634 = 3;
								end
								if (10 == FlatIdent_86634) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_86634 = 11;
								end
							end
						end
						VIP = VIP + 1;
						break;
					end
					if (FlatIdent_5ED46 == 0) then
						Inst = Instr[VIP];
						Enum = Inst[1];
						FlatIdent_5ED46 = 1;
					end
				end
			end
		end;
	end
	return Wrap(Deserialize(), {}, vmenv)(...);
end
return VMCall("LOL!5F3O00028O00026O002040030C3O00426F72646572436F6C6F723303063O00436F6C6F723303073O0066726F6D524742030F3O00426F7264657253697A65506978656C03083O00506F736974696F6E03053O005544696D322O033O006E65770273D516804190D63F03043O0053697A65025O00407440026O003B4003043O00466F6E7403043O00456E756D03043O0054657874030A3O0054657874436F6C6F7233025O00E06F40030A3O00546578745363616C65642O01026O002240027O0040030E3O005A496E6465784265686176696F7203073O005369626C696E6703043O004E616D6503073O004B65794D61696E03063O00506172656E7403103O004261636B67726F756E64436F6C6F7233025O00804840022ED1B41F841BD83F02D99879A085ACD83F025O00A06040026O00084003063O0041637469766503093O004472612O6761626C6503083O004B6579456E746572025O00C05240024EAE0681C57CC83F027C0E068025D5E43F026O001040026O001440030B3O00546578745772612O706564030C3O00436F726E657252616469757303043O005544696D026O00364003053O005465787431026O001840026O006940026O00434003113O00506C616365686F6C646572436F6C6F7233030F3O00506C616365686F6C6465725465787403133O00456E74657220596F75204B6579204865726521034O0003083O005465787453697A65026O002C4003163O00546578745374726F6B655472616E73706172656E6379026O00264003043O00506C617903093O00466F6375734C6F737403073O00436F2O6E656374026O001C4003053O00546578743203163O004261636B67726F756E645472616E73706172656E6379026O00F03F03103O00546578745472616E73706172656E637903093O0054772O656E496E666F030B3O00456173696E675374796C6503043O0051756164030F3O00456173696E67446972656374696F6E2O033O004F7574026O00244003063O00437265617465026O00E83F02C012BCDF7038AC3F03083O00496E7374616E636503053O004672616D6503073O0054657874426F7803083O005549436F726E657203093O00546578744C6162656C03093O004B657953797374656D03043O0067616D6503073O00506C6179657273030B3O004C6F63616C506C61796572030C3O0057616974466F724368696C6403093O00506C61796572477569030F3O0048734C6A6433417369346A6D666B6103113O00456D6F726561204B65792053797374656D03293O004A6F696E20446973636F72642120682O7470733A2O2F646973636F72642E2O672F6737333247446172030A3O00467265646F6B614F6E65030A3O006C6F6164737472696E6703073O00482O747047657403573O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F55736572333233393534332F74777975696F7472353669397569362F6D61696E2F73642O677569736572677969657162792E6C7561030A3O0047657453657276696365030C3O0054772O656E5365727669636503093O005363722O656E477569007E012O00123D3O00014O0035000100173O0026343O002A000100020004323O002A0001001202001800043O00203900180018000500122O001900013O00122O001A00013O00122O001B00016O0018001B000200102O000E0003001800302O000E0006000100122O001800083O00202O00180018000900122O001900013O001205001A00013O00122O001B000A3O00122O001C00016O0018001C000200102O000E0007001800122O001800083O00202O00180018000900122O001900013O00122O001A000C3O00122O001B00013O00123D001C000D4O00230018001C000200102O000E000B001800122O0018000F3O00202O00180018000E4O00180018000400102O000E000E001800102O000E0010000300122O001800043O00202O00180018000500122O001900123O00123D001A00123O00123D001B00124O00400018001B0002001029000E00110018003042000E0013001400123D3O00153O0026343O0052000100160004323O005200010012020018000F3O00202O00180018001700202O00180018001800102O00080017001800302O00090019001A00102O0009001B000800122O001800043O00202O00180018000500122O0019001D3O00122O001A001D3O00122O001B001D4O00400018001B00020010040009001C001800122O001800043O00202O00180018000500122O001900013O00122O001A00013O00122O001B00016O0018001B000200102O00090003001800302O00090006000100122O001800083O00201600180018000900123F0019001E3O00122O001A00013O00122O001B001F3O00122O001C00016O0018001C000200102O00090007001800122O001800083O00202O00180018000900122O001900013O00122O001A000C3O001215001B00013O00122O001C00206O0018001C000200102O0009000B001800124O00213O0026343O0070000100210004323O0070000100304200090022001400301F00090023001400302O000A0019002400102O000A001B000900122O001800043O00202O00180018000500122O001900253O00122O001A00253O00122O001B00256O0018001B000200102O000A001C0018001237001800043O00202O00180018000500122O001900013O00122O001A00013O00122O001B00016O0018001B000200102O000A0003001800302O000A0006000100122O001800083O00202O00180018000900123D001900263O00123D001A00013O001215001B00273O00122O001C00016O0018001C000200102O000A0007001800124O00283O0026343O008B000100290004323O008B0001003042000A002A00140012110018002C3O00202O00180018000900122O001900013O00122O001A002D6O0018001A000200102O000B002B001800102O000B001B000A00122O0018002C3O00202O00180018000900122O001900013O00123D001A002D4O00380018001A000200102O000C002B001800102O000C001B000900302O000D0019002E00102O000D001B000900122O001800043O00202O00180018000500122O001900123O00122O001A00123O00122O001B00124O00400018001B0002001029000D001C001800123D3O002F3O000E3A002800AC00013O0004323O00AC0001001202001800083O00202E00180018000900122O001900013O00122O001A00303O00122O001B00013O00122O001C00316O0018001C000200102O000A000B001800122O0018000F3O00202O00180018000E4O001800180004001029000A000E0018001230001800043O00202O00180018000500122O001900123O00122O001A00123O00122O001B00126O0018001B000200102O000A0032001800302O000A0033003400302O000A0010003500122O001800043O002016001800180005001210001900123O00122O001A00123O00122O001B00126O0018001B000200102O000A0011001800302O000A0036003700302O000A0038000100124O00293O0026343O00C4000100390004323O00C4000100201800180013003A2O003300180002000100202O00180014003A4O00180002000100202O00180016003A4O0018000200014O001700173O00062200173O000100082O00083O000A4O00083O00014O00083O00074O00083O00094O00083O00064O00083O00084O00083O000D4O00083O000E3O0020160018000A003B00201800180018003C000622001A0001000100012O00083O00174O002D0018001A00010004323O007C2O010026343O00D50001003D0004323O00D50001003042000D00130014003006000D0036003700302O000D0038000100302O000D002A001400302O000E0019003E00102O000E001B000900122O001800043O00202O00180018000500122O001900123O00122O001A00123O00122O001B00124O00400018001B0002001029000E001C0018003042000E003F004000123D3O00023O0026343O00EA000100150004323O00EA0001003042000E00360037003012000E0038000100302O000E002A001400302O0009003F004000302O000D0041004000302O000E0041004000302O000A003F004000122O001800423O00202O00180018000900122O001900163O00122O001A000F3O002016001A001A0043002024001A001A004400122O001B000F3O00202O001B001B004500202O001B001B00464O0018001B00024O000F00183O00124O00473O000E3A004700102O013O0004323O00102O012O002700183O000100300B0018003F00014O001000183O00202O0018000700484O001A00096O001B000F6O001C00106O0018001C00024O001100186O00183O000100302O0018004100012O0008001200183O0020210018000700484O001A000D6O001B000F6O001C00126O0018001C00024O001300183O00202O0018000700484O001A000E6O001B000F6O001C00124O00400018001C00022O0001001400186O00183O000100302O0018003F00494O001500183O00202O0018000700484O001A000A6O001B000F6O001C00156O0018001C00024O001600183O00201800180011003A2O000900180002000100123D3O00393O000E3A002F00382O013O0004323O00382O01003042000D003F0040001237001800043O00202O00180018000500122O001900013O00122O001A00013O00122O001B00016O0018001B000200102O000D0003001800302O000D0006000100122O001800083O00202O00180018000900123F001900013O00122O001A00013O00122O001B004A3O00122O001C00016O0018001C000200102O000D0007001800122O001800083O00202O00180018000900122O001900013O00122O001A000C3O00123D001B00013O00123D001C000D4O00230018001C000200102O000D000B001800122O0018000F3O00202O00180018000E4O00180018000400102O000D000E001800102O000D0010000200122O001800043O00202O00180018000500122O001900123O001215001A00123O00122O001B00126O0018001B000200102O000D0011001800124O003D3O0026343O00612O0100400004323O00612O010012020018004B3O00200C00180018000900122O0019004C6O0018000200024O000900183O00122O0018004B3O00202O00180018000900122O0019004D6O0018000200024O000A00183O00122O0018004B3O00200C00180018000900122O0019004E6O0018000200024O000B00183O00122O0018004B3O00202O00180018000900122O0019004E6O0018000200024O000C00183O00122O0018004B3O00201600180018000900123D0019004F4O000F0018000200024O000D00183O00122O0018004B3O00202O00180018000900122O0019004F6O0018000200024O000E00183O00302O00080019005000122O001800513O00202O00180018005200201600180018005300203600180018005400122O001A00556O0018001A000200102O0008001B001800124O00163O0026343O0002000100010004323O0002000100123D000100563O001213000200573O00122O000300583O00122O000400593O00122O000500593O00122O0018005A3O00122O001900513O00202O00190019005B00122O001B005C6O001C00016O0019001C4O003C00183O00022O0003000600183O00122O001800513O00202O00180018005D00122O001A005E6O0018001A00024O000700183O00122O0018004B3O00202O00180018000900122O0019005F6O0018000200022O0008000800183O00123D3O00403O0004323O000200012O00148O001A3O00013O00023O001A3O00028O0003093O0054772O656E496E666F2O033O006E6577026O00F03F03043O00456E756D030B3O00456173696E675374796C6503043O0051756164030F3O00456173696E67446972656374696F6E2O033O004F757403043O0054657874026O000840027O004003163O004261636B67726F756E645472616E73706172656E637903063O0043726561746503093O00436F6D706C6574656403073O00436F2O6E65637403043O0077616974026O00144003043O00506C617903053O007072696E74030C3O00436F2O72656374204B657921030C3O00426F72646572436F6C6F723303063O00436F6C6F7233026O00104003103O00546578745472616E73706172656E6379030A3O0057726F6E67204B65792100E03O00123D3O00014O0035000100023O0026343O0011000100010004323O00110001001202000300023O00202C00030003000300122O000400043O00122O000500053O00202O00050005000600202O00050005000700122O000600053O00202O00060006000800202O0006000600094O0003000600024O000100036O000200023O00124O00043O0026343O0002000100040004323O000200012O000700035O00201600030003000A2O0007000400013O00062B000300B7000100040004323O00B7000100123D000300014O00350004000A3O002634000300A80001000B0004323O00A800012O0035000A000A3O0026340004003D0001000C0004323O003D000100123D000B00013O002634000B0031000100010004323O00310001001202000C00023O002026000C000C000300122O000D000C3O00122O000E00053O00202O000E000E000600202O000E000E000700122O000F00053O00202O000F000F000800202O000F000F00094O000C000F00024O0005000C6O000C3O000100302O000C000D00044O0006000C3O00122O000B00043O002634000B0020000100040004323O002000012O0007000C00023O00201B000C000C000E4O000E00036O000F00056O001000066O000C001000024O0007000C3O00122O0004000B3O00044O003D00010004323O0020000100263400040052000100040004323O0052000100123D000B00013O002634000B0046000100040004323O004600012O0007000C00044O0020000C0001000100123D0004000C3O0004323O00520001002634000B0040000100010004323O00400001002016000C0002000F002018000C000C0010000622000E3O000100012O00078O003E000C000E000100122O000C00113O00122O000D00046O000C0002000100122O000B00043O00044O004000010026340004005C000100120004323O005C0001002018000B000A00132O0009000B00020001002016000B0007000F002018000B000B0010000622000D0001000100012O00073O00054O002D000B000D00010004323O00DF000100263400040072000100010004323O00720001001202000B00143O001225000C00156O000B000200014O000B00023O00202O000B000B000E4O000D8O000E00016O000F3O000100122O001000173O00202O00100010000300122O001100013O00122O001200043O00122O001300016O00100013000200102O000F001600104O000B000F00024O0002000B3O00202O000B000200134O000B0002000100122O000400043O002634000400950001000B0004323O0095000100123D000B00013O002634000B0081000100040004323O008100012O0007000C00023O00200D000C000C000E4O000E8O000F00056O00103O000100302O0010000D00044O000C001000024O000A000C3O00122O000400183O00044O00950001000E3A000100750001000B0004323O007500012O0007000C00023O002043000C000C000E4O000E00066O000F00056O00103O000100302O0010001900044O000C001000024O0008000C6O000C00023O00202O000C000C000E4O000E00076O000F00056O00103O000100302O0010001900044O000C001000024O0009000C3O00122O000B00043O00044O007500010026340004001D000100180004323O001D000100123D000B00013O002634000B009E000100040004323O009E0001002018000C000900132O0009000C0002000100123D000400123O0004323O001D0001002634000B0098000100010004323O00980001002018000C000700132O001D000C0002000100202O000C000800134O000C0002000100122O000B00043O00044O009800010004323O001D00010004323O00DF0001002634000300AC0001000C0004323O00AC00012O0035000800093O00123D0003000B3O002634000300B1000100010004323O00B1000100123D000400014O0035000500053O00123D000300043O0026340003001A000100040004323O001A00012O0035000600073O00123D0003000C3O0004323O001A00010004323O00DF000100123D000300013O002634000300CC000100010004323O00CC0001001202000400143O0012190005001A6O0004000200014O000400023O00202O00040004000E4O00068O000700016O00083O000100122O000900173O00202O00090009000300122O000A00043O00122O000B00013O00122O000C00016O0009000C000200102O0008001600094O0004000800024O000200043O00122O000300043O002634000300D20001000C0004323O00D20001001202000400113O00123D000500044O00090004000200010004323O00DF0001002634000300B8000100040004323O00B800010020180004000200132O000900040002000100201600040002000F00201800040004001000062200060002000100012O00078O002D00040006000100123D0003000C3O0004323O00B800010004323O00DF00010004323O000200012O001A3O00013O00033O00043O00030C3O00426F72646572436F6C6F723303063O00436F6C6F72332O033O006E6577029O00094O003B7O00122O000100023O00202O00010001000300122O000200043O00122O000300043O00122O000400046O00010004000200104O000100016O00017O00013O0003073O0044657374726F7900044O00077O0020185O00012O00093O000200012O001A3O00017O00043O00030C3O00426F72646572436F6C6F723303063O00436F6C6F72332O033O006E6577029O00094O003B7O00122O000100023O00202O00010001000300122O000200043O00122O000300043O00122O000400046O00010004000200104O000100016O00019O002O0001053O00061C3O000400013O0004323O000400012O000700016O00200001000100012O001A3O00017O00", GetFEnv(), ...);