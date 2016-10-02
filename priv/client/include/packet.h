enum operation {
    VOID
    #include "operations"
}
enum domain {
    VOID
    #include "domains"
}
class Packet {
public:
    std::string parse();
private:
}
