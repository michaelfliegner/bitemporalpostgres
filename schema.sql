DROP SCHEMA PUBLIC CASCADE;
CREATE SCHEMA PUBLIC;
SET search_path TO PUBLIC;
--
-- PostgreSQL database dump
--

-- Dumped from database version 14.8
-- Dumped by pg_dump version 14.8

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
--SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;


--
-- Name: histories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE histories (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY NOT NULL,
    htype CHARACTER varying NOT NULL
);

--
-- Name: versions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE versions (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ref_history UUID REFERENCES histories,
    committed boolean NOT NULL
);

--
-- Name: validities; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE validities (
     id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ref_version BIGINT REFERENCES versions,
    valid_txn tstzrange,
    valid_ref tstzrange
);


--
-- Name: contracts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE contracts (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ref_history uuid REFERENCES histories
);

--
-- Name: contract_revisions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE contract_revisions (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ref_component BIGINT REFERENCES contracts,
    ref_valid int8range,
    content JSONB
);
