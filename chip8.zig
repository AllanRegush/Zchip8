const std = @import("std");

const CPU = struct {
    current_operation: u16,
    registers: [2]u8,

    pub fn run(self: *CPU) void {
        var opcode = self.current_operation;

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

    fn add_xy(self: *CPU, x: u8, y: u8) void {
        self.registers[x] += self.registers[y];
    }
};

pub fn main() void {
    var cpu = CPU {
        .current_operation = 0,
        .registers = [_]u8{ 5, 10 },
    };

    cpu.current_operation = 0x8014;
    cpu.run();
    std.debug.print("Registers, 0: {}, 1: {}", .{ cpu.registers[0], cpu.registers[1] });
}