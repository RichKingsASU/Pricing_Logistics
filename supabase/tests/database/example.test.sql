BEGIN;

-- Plan the tests
SELECT plan(1);

-- Run the tests
SELECT pass('This is a test to verify pgTAP is working');

-- Finish the tests and clean up
SELECT * FROM finish();

ROLLBACK;
