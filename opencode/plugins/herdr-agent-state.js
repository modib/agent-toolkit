// installed by herdr
// safe to edit. this plugin only activates inside herdr-managed panes.
// HERDR_INTEGRATION_ID=opencode
// HERDR_INTEGRATION_VERSION=1

import net from "node:net";

const SOURCE = "herdr:opencode";
let reportSeq = Date.now() * 1000;

function nextReportSeq() {
  reportSeq += 1;
  return reportSeq;
}

function reportState(action) {
  const paneId = process.env.HERDR_PANE_ID;
  const socketPath = process.env.HERDR_SOCKET_PATH;

  if (!paneId || !socketPath) {
    return Promise.resolve();
  }

  const requestId = `${SOURCE}:${Date.now()}:${Math.floor(Math.random() * 1_000_000)
    .toString()
    .padStart(6, "0")}`;
  const request = {
    id: requestId,
    method: action === "release" ? "pane.release_agent" : "pane.report_agent",
    params:
      action === "release"
        ? {
            pane_id: paneId,
            source: SOURCE,
            agent: "opencode",
            seq: nextReportSeq(),
          }
        : {
            pane_id: paneId,
            source: SOURCE,
            agent: "opencode",
            state: action,
            seq: nextReportSeq(),
          },
  };

  return new Promise((resolve) => {
    const client = net.createConnection(socketPath, () => {
      client.write(`${JSON.stringify(request)}\n`);
    });

    const finish = () => {
      client.destroy();
      resolve();
    };

    client.setTimeout(500, finish);
    client.on("data", finish);
    client.on("error", finish);
    client.on("end", finish);
    client.on("close", resolve);
  });
}

function releaseSync() {
  const paneId = process.env.HERDR_PANE_ID;
  const socketPath = process.env.HERDR_SOCKET_PATH;
  if (!paneId || !socketPath) return;

  const request = {
    id: `${SOURCE}:${Date.now()}:${Math.floor(Math.random() * 1_000_000).toString().padStart(6, "0")}`,
    method: "pane.release_agent",
    params: {
      pane_id: paneId,
      source: SOURCE,
      agent: "opencode",
      seq: nextReportSeq(),
    },
  };

  try {
    const client = net.createConnection(socketPath, () => {
      client.write(`${JSON.stringify(request)}\n`);
      client.end();
    });
    client.unref();
    client.on("error", () => {});
  } catch {
    // process is shutting down — best effort only
  }
}

export const HerdrAgentStatePlugin = async () => {
  if (
    process.env.HERDR_ENV !== "1" ||
    !process.env.HERDR_SOCKET_PATH ||
    !process.env.HERDR_PANE_ID
  ) {
    return {};
  }

  // Report release when process exits gracefully
  process.on("beforeExit", releaseSync);
  process.on("SIGINT", () => { releaseSync(); process.exit(128 + 2); });
  process.on("SIGTERM", () => { releaseSync(); process.exit(128 + 15); });
  process.on("SIGHUP", () => { releaseSync(); process.exit(128 + 1); });
  process.on("SIGQUIT", () => { releaseSync(); process.exit(128 + 3); });

  return {
    event: async ({ event }) => {
      const type = event?.type;
      const properties = event?.properties ?? {};

      switch (type) {
        case "permission.asked":
        case "question.asked":
          await reportState("blocked");
          break;
        case "permission.replied": {
          const reply = properties.reply ?? properties.response;
          if (reply === "reject") {
            await reportState("idle");
          } else if (reply === "once" || reply === "always") {
            await reportState("working");
          }
          break;
        }
        case "question.replied":
          await reportState("working");
          break;
        case "question.rejected":
          await reportState("idle");
          break;
        case "session.status": {
          const status =
            typeof properties.status === "string"
              ? properties.status
              : properties.status?.type;
          if (status === "busy" || status === "retry") {
            await reportState("working");
          } else if (status === "idle") {
            await reportState("idle");
          }
          break;
        }
        case "session.idle":
          await reportState("idle");
          break;
        default:
          break;
      }
    },
  };
};
