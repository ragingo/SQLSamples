using System;
using System.Collections.Generic;
using System.Data.SqlTypes;
using System.IO;
using System.Linq;
using System.Media;
using System.Text;
using System.Threading.Tasks;
using Microsoft.SqlServer.Server;

namespace MSSqlUtils
{
	public class Collection
	{
		[SqlFunction]
		public static byte[] Take(SqlBytes binary, int count)
		{
			if (binary.IsNull)
			{
				return null;
			}
			byte[] buf = new byte[count];
			binary.Read(0, buf, 0, count);
			return buf;
		}

		[SqlFunction]
		public static byte[] Skip(SqlBytes binary, int count)
		{
			if (binary.IsNull)
			{
				return null;
			}
			byte[] buf = new byte[binary.Length - count];
			binary.Read(count, buf, 0, buf.Length);
			return buf;
		}

		[SqlFunction]
		public static byte[] Range(SqlBytes binary, int from, int count)
		{
			if (binary.IsNull)
			{
				return null;
			}
			byte[] buf = new byte[count];
			binary.Read(from, buf, 0, count);
			return buf;
		}

		[SqlFunction]
		public static long Length(SqlBytes binary)
		{
			return binary.Length;
		}

		[SqlFunction]
		public static byte[] Reverse(SqlBytes binary)
		{
			if (binary.IsNull)
			{
				return null;
			}
			byte[] buf = binary.Value;
			Array.Reverse(buf);
			return buf;
		}
	}

	public class MultiMedia
	{
		[SqlProcedure]
		public static void PlaySound(SqlString path)
		{
			if (string.IsNullOrEmpty(path.Value))
			{
				return;
			}
			if (!File.Exists(path.Value))
			{
				return;
			}
			new SoundPlayer(path.Value).PlaySync();
		}
	}
}
