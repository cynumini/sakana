#include "skn/types.cpp"

namespace skn {
namespace {
struct Color {
    u8 r;
    u8 g;
    u8 b;
    u8 a;

    constexpr Color() = default;

    constexpr Color(u8 r, u8 g, u8 b, u8 a) : r(r), g(g), b(b), a(a) {}

    constexpr Color(u32 value)
        : r(static_cast<u8>(value >> 24U)), g(static_cast<u8>(value >> 16U)),
          b(static_cast<u8>(value >> 8U)), a(static_cast<u8>(value)) {}
};

constexpr Color WHITE = 0xFFFFFFFF;
constexpr Color BLACK = 0x000000FF;
constexpr Color GRAY = 0x808080FF;
constexpr Color RED = 0xFF0000FF;
constexpr Color GREEN = 0x00FF00FF;
constexpr Color BLUE = 0x0000FFFF;
constexpr Color YELLOW = 0xFFFF00FF;
constexpr Color CYAN = 0x00FFFFFF;
constexpr Color MAGENTA = 0xFF00FFFF;
constexpr Color ORANGE = 0xFFA500FF;
constexpr Color PURPLE = 0x800080FF;
constexpr Color PINK = 0xFFC0CBFF;
constexpr Color BROWN = 0xA52A2AFF;
constexpr Color LIME = 0xBFFF00FF;
constexpr Color NAVY = 0x000080FF;
constexpr Color TEAL = 0x008080FF;
} // namespace
} // namespace skn
