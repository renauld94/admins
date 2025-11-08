#!/usr/bin/env python3
"""
Vietnamese Content Indexer & Catalog Builder
Scans all Vietnamese language resources and creates searchable index for AI agents
"""

import os
import json
import mimetypes
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Any
import hashlib

class VietnameseContentIndexer:
    def __init__(self, resources_dir: str = "/home/simon/Desktop/ressources/11-Vietnamese-Language/"):
        self.resources_dir = resources_dir
        self.index = {
            "metadata": {
                "scanned_at": datetime.now().isoformat(),
                "resource_directory": resources_dir,
                "total_resources": 0,
                "resource_types": {}
            },
            "resources": [],
            "by_type": {},
            "by_level": {},
            "glossary_index": [],
            "audio_index": [],
            "pdf_index": []
        }
    
    def scan_resources(self) -> Dict[str, Any]:
        """Scan all resources and build comprehensive index"""
        print(f"[INDEXER] Scanning Vietnamese resources from: {self.resources_dir}")
        
        resource_path = Path(self.resources_dir)
        if not resource_path.exists():
            print(f"[ERROR] Resource directory not found: {self.resources_dir}")
            return self.index
        
        # Scan all files
        for root, dirs, files in os.walk(resource_path):
            for filename in sorted(files):
                filepath = os.path.join(root, filename)
                try:
                    self._catalog_resource(filepath)
                except Exception as e:
                    print(f"[WARNING] Error cataloging {filename}: {e}")
        
        # Process metadata
        self.index["metadata"]["total_resources"] = len(self.index["resources"])
        self._analyze_content()
        
        print(f"[INDEXER] ✅ Indexed {self.index['metadata']['total_resources']} resources")
        return self.index
    
    def _catalog_resource(self, filepath: str):
        """Catalog a single resource"""
        filename = os.path.basename(filepath)
        filesize = os.path.getsize(filepath)
        
        # Determine resource type
        ext = os.path.splitext(filename)[1].lower()
        resource_type = self._categorize_type(ext)
        
        # Extract level from filename (Beginner, Intermediate, Advanced)
        level = self._extract_level(filename)
        
        # Create catalog entry
        entry = {
            "filename": filename,
            "filepath": filepath,
            "type": resource_type,
            "ext": ext,
            "size_mb": round(filesize / (1024*1024), 2),
            "level": level,
            "hash": self._quick_hash(filepath)[:8],
            "content_category": self._categorize_content(filename)
        }
        
        self.index["resources"].append(entry)
        
        # Index by type
        if resource_type not in self.index["by_type"]:
            self.index["by_type"][resource_type] = []
        self.index["by_type"][resource_type].append(filename)
        
        # Index by level
        if level not in self.index["by_level"]:
            self.index["by_level"][level] = []
        self.index["by_level"][level].append(filename)
        
        # Special indexing for audio and PDFs
        if resource_type == "audio":
            self.index["audio_index"].append({
                "filename": filename,
                "filepath": filepath,
                "size_mb": entry["size_mb"]
            })
        elif resource_type == "pdf":
            self.index["pdf_index"].append({
                "filename": filename,
                "filepath": filepath,
                "content": self._categorize_content(filename),
                "level": level
            })
        elif "glossary" in filename.lower() or "dictionary" in filename.lower():
            self.index["glossary_index"].append(filename)
    
    def _categorize_type(self, ext: str) -> str:
        """Categorize by file extension"""
        audio_exts = {'.mp3', '.wav', '.ogg', '.m4a', '.aac', '.flac'}
        video_exts = {'.mp4', '.avi', '.mkv', '.mov', '.flv', '.webm'}
        archive_exts = {'.rar', '.zip', '.7z', '.tar', '.gz'}
        doc_exts = {'.pdf', '.doc', '.docx', '.txt'}
        
        if ext in audio_exts:
            return "audio"
        elif ext in video_exts:
            return "video"
        elif ext in archive_exts:
            return "archive"
        elif ext in doc_exts:
            return "document"
        else:
            return "other"
    
    def _extract_level(self, filename: str) -> str:
        """Extract learning level from filename"""
        lower = filename.lower()
        if any(x in lower for x in ['beginner', 'basic', '01', '02', '03']):
            return "beginner"
        elif any(x in lower for x in ['intermediate', '04', '05', '06']):
            return "intermediate"
        elif any(x in lower for x in ['advanced', 'intermediate', '07', '08']):
            return "advanced"
        return "general"
    
    def _categorize_content(self, filename: str) -> str:
        """Categorize content topic"""
        lower = filename.lower()
        
        if any(x in lower for x in ['grammar', 'ngữ pháp']):
            return "grammar"
        elif any(x in lower for x in ['cook', 'food', 'eating']):
            return "culture_food"
        elif any(x in lower for x in ['culture', 'custom', 'vietnam war', 'history']):
            return "culture_history"
        elif any(x in lower for x in ['phrase', 'dictionary', 'glossary', 'vocab', 'words']):
            return "vocabulary"
        elif any(x in lower for x in ['read', 'reader', 'story', 'harry potter', 'grimm', 'tale']):
            return "reading"
        elif any(x in lower for x in ['lonely planet', 'travel', 'guide']):
            return "travel_culture"
        return "general"
    
    def _quick_hash(self, filepath: str) -> str:
        """Quick file hash for tracking"""
        try:
            with open(filepath, 'rb') as f:
                return hashlib.md5(f.read(1024)).hexdigest()
        except:
            return "unknown"
    
    def _analyze_content(self):
        """Analyze and summarize indexed content"""
        if not self.index["resources"]:
            return
        
        # Count types
        for resource_type in set(r["type"] for r in self.index["resources"]):
            count = len([r for r in self.index["resources"] if r["type"] == resource_type])
            self.index["metadata"]["resource_types"][resource_type] = count
    
    def get_index_summary(self) -> str:
        """Get human-readable summary of indexed content"""
        summary = []
        summary.append("\n" + "="*70)
        summary.append("VIETNAMESE LANGUAGE RESOURCES INDEX")
        summary.append("="*70)
        summary.append(f"Total Resources: {self.index['metadata']['total_resources']}")
        summary.append(f"Scanned: {self.index['metadata']['scanned_at']}\n")
        
        summary.append("RESOURCE TYPES:")
        for rtype, count in self.index["metadata"]["resource_types"].items():
            summary.append(f"  • {rtype.upper()}: {count} files")
        
        summary.append("\nRESOURCES BY LEVEL:")
        for level in ['beginner', 'intermediate', 'advanced', 'general']:
            count = len(self.index["by_level"].get(level, []))
            if count > 0:
                summary.append(f"  • {level.upper()}: {count} resources")
        
        summary.append(f"\nGLOSSARIES/DICTIONARIES: {len(self.index['glossary_index'])}")
        summary.append(f"AUDIO FILES: {len(self.index['audio_index'])}")
        summary.append(f"PDF DOCUMENTS: {len(self.index['pdf_index'])}")
        
        # Sample resources
        summary.append("\nSAMPLE RESOURCES (First 10):")
        for r in self.index["resources"][:10]:
            summary.append(f"  • {r['filename'][:50]}... ({r['type']}, {r['size_mb']}MB)")
        
        summary.append("="*70 + "\n")
        return "\n".join(summary)
    
    def save_index(self, output_path: str = "/home/simon/Learning-Management-System-Academy/data/vietnamese_content_index.json"):
        """Save index to JSON file"""
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(self.index, f, indent=2, ensure_ascii=False)
        print(f"[INDEXER] 📁 Index saved to: {output_path}")
        return output_path


def main():
    # Create and run indexer
    indexer = VietnameseContentIndexer()
    indexer.scan_resources()
    
    # Print summary
    print(indexer.get_index_summary())
    
    # Save index
    index_path = indexer.save_index()
    
    # Return paths for use by content generation
    return {
        "index_path": index_path,
        "index": indexer.index,
        "audio_files": indexer.index["audio_index"],
        "pdf_files": indexer.index["pdf_index"],
        "glossaries": indexer.index["glossary_index"]
    }


if __name__ == "__main__":
    main()
