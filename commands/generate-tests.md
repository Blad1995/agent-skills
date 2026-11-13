# generate-tests
1. Check what changed in current branch compared to master including non-committed changes
2. Find relevant test files
3. Load domain glossary from Forgetful MCP if available (concepts that relate to the tested logic).
4. Implement basic integration tests (preferable) for the new changes and adapt existing tests
5. Verify that the tests work afterwards
6. Run pre-commit to fix formatting and detect linting and typing issues
