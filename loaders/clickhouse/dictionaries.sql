create database if not exists ot;
create table if not exists ot.v2gw (
    source_id String,
    weight Float64
) Engine = Dictionary(v2gw);
