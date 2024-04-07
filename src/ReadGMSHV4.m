function [info,physTag2Name,physName2Tag,geoEntity,V,ELEM,pedcPair] = ReadGMSHV4(filename)
% This function is modified by JS. Qiu
%
%     Extract entities contained in a single GMSH file in format v4.1 
%      Coded by Manuel A. Diaz @ Pprime | Univ-Poitiers, 2022.01.21
%
% Output:
%     V: the vertices (nodes coordinates) -- (Nx3) array
%    VE: volumetric elements (tetrahedrons) -- structure
%    SE: surface elements (triangles,quads) -- structure
%    LE: curvilinear elements (lines/edges) -- structure
%    PE: point elements (singular vertices) -- structure
%    mapPhysNames: maps phys.tag --> phys.name  -- map structure
%    info: version, format, endian test -- structure
%
% Example: [info,physTag2Name,physName2Tag,geoEntity,V,ELEM,pedcPair] = ReadGMSHV4('./msh/unit_cell.msh');

%% Read all sections
file = fileread(filename);

% Erase return-carrige character: (\r)
strFile = erase(file,char(13));

%% 1. Read Mesh Format
[info] = ReadGMSHMeshFormat(strFile);

%% 2. Read Physical Names
[physTag2Name, physName2Tag, info] = ReadGMSHPhysicalName(strFile, info);

%% 3. Read Entities
[geoEntity] = ReadGMSHEntity(strFile);

%% 4. Read Nodes
[V,info] = ReadGMSHNode(strFile, info);

%% 5. Read Elements
[ELEM,info] = ReadGMSHMesh(strFile, geoEntity, info);

%% 6. Read Periodic
pedcPair = ReadGMSHPerodic(strFile);

