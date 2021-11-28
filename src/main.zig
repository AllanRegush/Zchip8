const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;

const CPU = struct {
    // current_operation: u16,
    program_counter: u16,
    registers: [16]u8,
    memory: [0x1000]u8,
    
    pub fn run(self: *CPU) void {

        while (self.program_counter < 6) {
            const opcode: u16 = self.read_opcode();
            self.program_counter += 2;

            switch(opcode & 0xF000) {
                0x8000 => switch (opcode & 0xF) {
                        0x4 => {
                            const x: u8 = @truncate(u8, ((opcode & 0x0F00) >> 8));
                            const y: u8 = @truncate(u8,((opcode & 0x00F0) >> 4)); 
                            self.add_xy(x, y);
                        },
                        else => {},
                    },
            else => {},
            }
        }
    }

    fn add_xy(self: *CPU, x: u8, y: u8) void {
        const lhd = self.registers[x];
        const rhd = self.registers[y];
        var over_flow: u8 = 0;
        const is_overflow = @addWithOverflow(u8, lhd, rhd, &over_flow);
        self.registers[x] = lhd + rhd;
        if (is_overflow) {
            self.registers[0xF] = 1;
        } else {
            self.registers[0xF] = 0;
        }
    }

    pub fn read_opcode(self: *CPU) u16 {
        const pc: u16     = self.program_counter;
        const op_high: u8 = self.memory[pc];
        const op_low : u8 = self.memory[pc + 1];
        const result: u16 = @as(u16, op_high) << 8  | op_low;
        return result;
    }

    pub fn dump(self: *CPU) void {
        print("CPU: \nProgram Counter: {}\n", .{ self.program_counter });
        for (self.registers) |r| {
            print("{}", . {r});
        }
        print("\nMemory:\n", .{});
        for (self.memory) |m| {
            print("{}", . {m});
        }
        print("\n", .{});
    }
};

pub fn main() void {
    var cpu = CPU {
        .program_counter = 0,
        .registers = [_]u8{0} ** 16,
        .memory = [_]u8{0} ** 0x1000,
    };

    cpu.registers[0] = 5;
    cpu.registers[1] = 10;
    cpu.registers[2] = 10;
    cpu.registers[3] = 10;

    const mem = &cpu.memory;
    mem[0] = 0x80; mem[1] = 0x14;
    mem[2] = 0x80; mem[3] = 0x24;
    mem[4] = 0x80; mem[5] = 0x34;
    cpu.dump();
    cpu.run();
    assert(cpu.registers[0] == 35);
    cpu.dump();
}