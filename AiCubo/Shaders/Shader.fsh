//
//  Shader.fsh
//  AiCubo
//
//  Created by Max Bilbow on 26/03/2015.
//  Copyright (c) 2015 Rattle Media Ltd. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
