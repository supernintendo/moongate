enum operation {
    MESSAGE
    ADD
    REMOVE
    JOIN
    LEAVE
    SET
    MUTATE
    REQUEST
    PING
    STATUS
}
enum domain {
    WORLD
    STAGE
    POOL
}
class Packet {
public:
    std::string parse();
private:
}
