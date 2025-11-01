package RAM_shared_pkg;
  // Generic shared types & enums used across the environment.
  // TODO: Add/replace enums and typedefs that match your DUT.

int error_count;
int correct_count;

typedef enum  {WRITE_ADDR=2'b00, WRITE_DATA=2'b01, READ_ADDR=2'b10, READ_DATA=2'b11} addr_type_e;

endpackage : RAM_shared_pkg