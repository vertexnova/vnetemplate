/* ---------------------------------------------------------------------
 * Copyright (c) 2026 Ajeet Singh Yadav. All rights reserved.
 * Licensed under the Apache License, Version 2.0 (the "License")
 *
 * Author:    Ajeet Singh Yadav
 * Created:   February 2026
 *
 * Autodoc:   yes
 * ----------------------------------------------------------------------
 */

#include "vertexnova/template/template.h"
#include <iostream>

int main() {
    using namespace vne::template_ns;

    std::cout << hello() << std::endl;
    std::cout << "Version: " << get_version() << std::endl;

    return 0;
}
