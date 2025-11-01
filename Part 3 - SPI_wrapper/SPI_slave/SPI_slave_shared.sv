package SPI_slave_shared_pkg;
  // Generic shared types & enums used across the environment.
  // TODO: Add/replace enums and typedefs that match your DUT.
typedef enum { IDLE, WRITE, CHK_CMD, READ_ADD, READ_DATA } state_t;
int correct_count;
int error_count;
endpackage : SPI_slave_shared_pkg

