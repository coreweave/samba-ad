module.exports = {
  branch: "master",
  repositoryUrl: "git@github.com:coreweave/samba-ad.git",
  plugins: [
    [
      "@semantic-release/commit-analyzer",
      {
        preset: "angular",
        releaseRules: [
          { type: "feature", release: "minor" },
          { type: "update", release: "minor" },
          { type: "refactor", release: "patch" },
          { type: "bugfix", release: "patch" },
          { type: "refactor", release: "patch" },
        ],
        parserOpts: {
          noteKeywords: ["BREAKING CHANGE", "BREAKING CHANGES"],
        },
      },
    ],
    "@semantic-release/release-notes-generator",
    [
      "@semantic-release/changelog",
      {
        "changelogFile": "docs/CHANGELOG.md"
      }
    ],
    ["@semantic-release/github", {
      "assets": [
        {"path": "docs/CHANGELOG.md", "label": "Changelog"}
      ]
    }],
    [
      "@semantic-release/exec",
      {
        prepareCmd:
          'echo "BUILD_VERSION=\\"${nextRelease.version}\\"" > artifacts.env',
        publishCmd: "true",
      },
    ],
  ],
};
